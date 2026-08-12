from flask import Blueprint,render_template,request,redirect,url_for,session,flash,abort,current_app
from utils.auth import login_required,student_required
from werkzeug.security import check_password_hash
from werkzeug.utils import secure_filename
from students_module.students_models import UserModel,StudentModel,NotificationModel,ActivityModel
import os
from utils.db import mysql 
from datetime import datetime,date


ALLOWED_EXTENSIONS={'pdf'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

student=Blueprint('student', __name__, template_folder='students_views')

@student.before_request
def track_student_activity():
    student_id=session.get('student_id')
    if not student_id:
        return
    
    if request.path.startswith('/static'):
        return
    
    log_id=session.pop('current_log_id',None)

    if log_id:
        ActivityModel.log_exit(log_id)

    new_log_id=ActivityModel.log_enter(
        student_id=student_id,
        page_name=request.endpoint or request.path,
        page_url=request.path,
        ip_address=request.remote_addr
    )
    session['current_log_id']=new_log_id


@student.route('/track_exit',methods=['POST'])
def track_exit():
    log_id=session.pop('current_log_id',None)

    if log_id:
        ActivityModel.log_exit(log_id)
    return '',204



@student.route('/student_login',methods=['GET','POST'])
def student_login():
    if request.method=='POST':
        email=request.form['email']
        password=request.form['password']
        remember='remember_me' in request.form

        user=UserModel.get_user_by_email(email)
        if user and check_password_hash(user['password'],password):
            student_obj=StudentModel.get_student_by_user_id(user['user_id'])
            if student_obj:
                session['user_id']=user['user_id']
                session['role']='student'
                session['student_id']=student_obj['student_id']
                session['date']=datetime.now()
                session.permanent=remember
                return redirect(url_for('student.student_dashboard'))
            else:
                return redirect(url_for('student.student_login'))
        else:
            return redirect(url_for('student.student_login'))
    return render_template('student_login.html')


@student.route('/student_base',methods=['GET'])
@student_required
def base():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))
    
    student_name=StudentModel.get_student_name_by_user_id(session['user_id'])
    return render_template('student_base.html',student_name=student_name)


@student.route('/student_profile',methods=['GET', 'POST'])
@student_required
def student_profile():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))

    student_id=session['student_id']
    student_obj=StudentModel.get_student_by_id(student_id)
    program=StudentModel.get_student_program_details(student_id)
    show_notification=request.method =='POST' and 'edit_request' in request.form
    return render_template('student_profile.html',student=student_obj,program=program,show_notification=show_notification)


@student.route('/student_dashboard',methods=['GET', 'POST'])
@student_required
def student_dashboard():
    cursor=mysql.connection.cursor()

    if session.get('role') != 'student':
        return redirect(url_for('main_view'))
    
    student_id=session['student_id']
    courses=StudentModel.get_enrolled_courses_by_student_id(student_id)
    if not courses:
        return render_template('student_dashboard.html', message="You are not enrolled in any courses yet.")

    course_ids=[course['course_id'] for course in courses]
    course_data=StudentModel.get_course_details_by_ids(course_ids)
    course_names={course['course_id']: course['course_name'] for course in course_data}

    submissions=StudentModel.get_student_submission_status(student_id)
    uploaded_assignments=[sub['course_id'] for sub in submissions if sub['submission_type'] == 'assignment']
    uploaded_quizzes=[sub['course_id'] for sub in submissions if sub['submission_type'] == 'quiz']

    teacher_rows=StudentModel.get_teachers_by_course_ids(course_ids)
    teacher_ids_by_course={}
    for row in teacher_rows:
        teacher_ids_by_course.setdefault(row['course_id'], []).append(row['teacher_id'])
    all_teacher_ids=list(set(tid for tids in teacher_ids_by_course.values() for tid in tids))
    teacher_info=StudentModel.get_teacher_info_by_ids(all_teacher_ids)

    schedule=StudentModel.get_course_schedule_by_course_ids(course_ids)
    for s in schedule:
        s['course_name']=course_names.get(s['course_id'], 'Unknown Course')

    active_notifications=NotificationModel.get_active_notifications(session['user_id'],'student')

    exam_data=None
    admit_card=None
    show_marquee=False
    cursor.execute('SELECT program_id FROM students WHERE student_id=%s',(student_id,))
    student_row=cursor.fetchone()
    if student_row:
        program_id=student_row['program_id'] 
        cursor.execute("""SELECT ex.exam_id,ex.exam_category,ex.exam_date,ex.exam_semester,
                   ex.start_time,ex.end_time,ex.location,ex.mode,ex.status,ps.program_name
                FROM exams ex
            JOIN programs ps ON ex.program_id=ps.program_id
            WHERE ex.program_id=%s
            AND ex.is_deleted =0
        """, (program_id,))
        exam_details=cursor.fetchall()
        today=date.today()
        upcoming=[ex for ex in exam_details if ex['exam_date'] >= today]  
        if upcoming:
            exam_data=upcoming
            show_marquee=True
            cursor.execute("""SELECT s.student_id,s.first_name,s.last_name,s.current_semester,
                       p.program_name
                FROM students s
                JOIN programs p ON s.program_id=p.program_id
                WHERE s.student_id=%s
            """, (student_id,))
            student_info=cursor.fetchone()
            exam_category=upcoming[0]['exam_category']
            exam_location=upcoming[0]['location'] or 'Class Room'

            admit_courses=[
                {
                    'course_id':c['course_id'],
                    'course_name':c['course_name'],
                    'exam_type':exam_category,
                    'location':exam_location,
                    'status':'Allowed',
                }
                for c in course_data
            ]

            admit_card={
                'student':student_info,
                'courses':admit_courses,
                'exam_date':upcoming[0]['exam_date'],
                'start_time':upcoming[0]['start_time'],
                'end_time':upcoming[0]['end_time'],
            }
        else:
            flash('No upcoming exams available.', 'info')

    cursor.close()
    return render_template(
        'student_dashboard.html', schedule=schedule, teacher=teacher_info, teacher_ids=teacher_ids_by_course,
        uploaded_assignments=uploaded_assignments,uploaded_quizzes=uploaded_quizzes,
        active_notifications=active_notifications,exam_data=exam_data,admit_card=admit_card,
        show_marquee=show_marquee)


@student.route('/student_fee', methods=['GET', 'POST'])
@student_required
def student_fee():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))
    
    student_id = session['student_id']
    fee_records = StudentModel.get_student_fee_records(student_id)
    return render_template("student_fee.html", fee_records=fee_records)



@student.route('/complaint_suggestion', methods=['GET', 'POST'])
@student_required
def complaint_suggestion():
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        user_id = session['user_id']
        StudentModel.insert_complaint_suggestion(title, description, user_id)
        return redirect(url_for('student.student_dashboard'))
    return render_template('complaint_suggestion.html')


@student.route('/notifications', methods=['GET', 'POST'])
@student_required
def notifications():
    user_id=session['user_id']
    complaint_status=StudentModel.get_complaint_status(user_id)
    return render_template('notifications.html',complaint_status=complaint_status)


@student.route('/upload_fee', methods=['GET', 'POST'])
@student_required
def upload_fee():
    student_id = session['student_id']
    if request.method == 'POST':
        month = request.form['month']
        fee_amount = request.form['fee_amount']
        front_voucher = request.files['front_voucher']
        back_voucher = request.files['back_voucher']
        if front_voucher and back_voucher:
            front_filename = f"student_{student_id}_front_{secure_filename(front_voucher.filename)}"
            back_filename = f"student_{student_id}_back_{secure_filename(back_voucher.filename)}"
            upload_folder = current_app.config['FEE_UPLOAD_FOLDER']
            os.makedirs(upload_folder, exist_ok=True)
            front_path = os.path.join(upload_folder, front_filename)
            back_path = os.path.join(upload_folder, back_filename)
            front_voucher.save(front_path)
            back_voucher.save(back_path)
            db_front_path = f"uploads/students_uploads/voucher_pics/{front_filename}"
            db_back_path = f"uploads/students_uploads/voucher_pics/{back_filename}"
            program_details = StudentModel.get_student_by_id(student_id)
            program_id = program_details['program_id'] if program_details else None
            StudentModel.upload_fee_voucher(
                student_id, program_id, month, fee_amount, db_front_path, db_back_path
            )
            return redirect(url_for('student.student_fee'))
    return render_template('upload_fee.html')




@student.route('/view_attendence', methods=['GET', 'POST'])
@student_required
def view_attendence():
    cursor=mysql.connection.cursor()
    student_id=session.get('student_id')
    if not student_id:
        flash("Student not logged in.", "danger")
        return redirect(url_for('student.student_login'))

    enrolled_courses=StudentModel.get_student_courses_for_attendance(student_id)
    attendance_report=[]
    for course in enrolled_courses:
        sc_id=course['student_course_id']
        total_lectures, attended=StudentModel.get_attendance_summary(sc_id)
        history=StudentModel.get_attendance_status_details(sc_id)
        perc=(attended / total_lectures * 100) if total_lectures > 0 else 0
        cursor.execute('''
            SELECT CONCAT(t.first_name, ' ', t.last_name) AS teacher_name
            FROM teacher_course tc
            JOIN teachers t ON tc.teacher_id = t.teacher_id
            JOIN student_course sc ON sc.course_id = tc.course_id
            WHERE sc.student_course_id = %s
            LIMIT 1
        ''', (sc_id,))
        teacher=cursor.fetchone()

        attendance_report.append({
            'course_name': course['course_name'],
            'credit_hours': course['credit_hours'],
            'total_lectures': total_lectures,
            'attended_lectures': attended,
            'percentage': round(perc, 1),
            'lecture_status': history,
            'teacher_name': teacher['teacher_name'] if teacher else '—'
        })

    cursor.close()
    return render_template('view_attendence.html',attendance_report=attendance_report)
    

@student.route('/view_grades', methods=['GET', 'POST'])
@student_required
def view_grades():
    student_id = session['student_id']
    student_details = StudentModel.get_student_by_id(student_id)
    all_marks = StudentModel.get_student_results_with_marks(student_id)
    return render_template(
        'view_grades.html',
        student_details=student_details,
        all_marks=all_marks
    )


@student.route('/course_registeration')
@student_required
def course_registeration():
    student_id=session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))

    student=StudentModel.get_student_by_id(student_id)
    is_reg_open=StudentModel.get_system_setting('is_course_reg_open')

    if str(is_reg_open) != '1':
        return render_template('course_registeration.html',
                               student=student,
                               reg_closed=True,
                               latest_summer=None,
                               selected=[],
                               can_register=False,
                               failed_count=0)
    
    improvements=StudentModel.get_improvement_subjects(student_id)
    retakes=StudentModel.get_retake_subjects(student_id)
    selected=improvements + retakes
    return render_template('course_registeration.html',student=student,selected=selected)


@student.route('/improvement_subject')
@student_required
def improvement_subject():
    student_id = session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))
    existing = StudentModel.get_existing_improvement_request(student_id)
    if existing:
        flash("Only one subject can be selected. Kindly contact the coordinator office for pending subject improvement.", "warning")
        return redirect(url_for('student.course_registeration'))
    max_semester = StudentModel.get_max_semester_passed(student_id)
    if max_semester < 1:
        flash("No previous semesters available for improvement.", "warning")
        return redirect(url_for('student.course_registeration'))
    courses = StudentModel.get_eligible_improvement_courses(student_id, max_semester)
    return render_template('improvement_subject.html', courses=courses)



@student.route('/delete_improvement/<int:improvement_id>', methods=['POST'])
@student_required
def delete_improvement(improvement_id):
    student_id=session.get('student_id')
    StudentModel.delete_improvement_subject(improvement_id,student_id)
    flash("Improvement subject removed successfully. You can now select a new one.", "success")
    return redirect(url_for('student.course_registeration'))



@student.route('/student/select_improvement/<int:course_id>', methods=['POST'])
@student_required
def select_improvement(course_id):
    student_id = session.get('student_id')
    cid = request.form.get('course_id', course_id)
    if not cid:
        abort(400)
    already = StudentModel.get_existing_improvement_request(student_id)
    if not already:
        StudentModel.add_improvement_subject(student_id, cid)
        user_id = session.get('user_id')
        title = 'Improvement subject selected'
        description = f'student {student_id} selected course {cid} for improvement.'
        StudentModel.add_notification(user_id, 'student', '01', 'coordinator', title, description, cid, 'pending')
    return redirect(url_for('student.course_registeration'))



@student.route('/help_desk', methods=['GET', 'POST'])
@student_required
def help_desk():
    return render_template('help_desk.html')



@student.route('/fail_subjects')
@student_required
def fail_subjects():
    student_id = session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))
    existing = StudentModel.get_existing_retake_request(student_id)
    if existing:
        flash("Only one subject can be selected for retake. Kindly contact the coordinator office for pending subject retake.", "warning")
        return redirect(url_for('student.course_registeration'))
    max_semester = StudentModel.get_max_semester_passed(student_id)
    if max_semester < 1:
        flash("No previous semesters available for retake.", "warning")
        return redirect(url_for('student.course_registeration'))
    courses = StudentModel.get_eligible_fail_subjects(student_id, max_semester)
    return render_template('fail_subjects.html', courses=courses)



@student.route('/student/select_fail/<int:course_id>', methods=['POST'])
@student_required
def select_fail(course_id):
    student_id = session.get('student_id')
    cid = request.form.get('course_id', course_id)
    if not cid:
        abort(400)
    already = StudentModel.get_existing_retake_request(student_id)
    if not already:
        StudentModel.add_fail_subject(student_id, cid)
        user_id = session.get('user_id')
        title = 'Retake subject selected'
        description = f'student {student_id} selected course {cid} for retake after fail.'
        StudentModel.add_notification(user_id, 'student', '01', 'coordinator', title, description, cid, 'pending')
    return redirect(url_for('student.course_registeration'))



@student.route('/delete_fail/<int:fail_id>', methods=['POST'])
@student_required
def delete_fail(fail_id):
    student_id = session.get('student_id')
    StudentModel.delete_fail_subject(fail_id, student_id)
    flash("Selected retake subject removed successfully. You can now select a new one.", "success")
    return redirect(url_for('student.course_registeration'))



@student.route('/semester_freeze', methods=['GET', 'POST'])
@student_required
def semester_freeze():
    student_id = session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))
    student = StudentModel.get_student_by_id(student_id)
    existing_request = StudentModel.get_active_semester_freeze_request(student_id)
    semester = StudentModel.get_last_recorded_semester(student_id)
    if existing_request:
        return render_template('semester_freeze.html', existing_request=existing_request, already_applied=True, semester=semester)
    if request.method == 'POST':
        reason = request.form.get('reason')
        if not semester:
            flash('No semester record found.', 'warning')
            return redirect(url_for('student.semester_freeze'))
        StudentModel.add_semester_freeze_request(student_id, semester, reason)
        flash('✅ Your semester freeze request has been submitted successfully!', 'success')
        return redirect(url_for('student.semester_freeze'))
    return render_template('semester_freeze.html', semester=semester, student=student, already_applied=False)


@student.route('/summer_semester')
@student_required
def summer_semester():
    student_id = session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))

    student=StudentModel.get_student_by_id(student_id)
    is_summer_open=StudentModel.get_system_setting('is_summer_app_open')

    if str(is_summer_open) != '1':
        return render_template('summer_semester.html',
                               student=student,
                               summer_closed=True,
                               latest_summer=None,
                               selected=[],
                               can_register=False,
                               failed_count=0)

    latest_summer=StudentModel.get_latest_summer_semester()
    selected_subjects=[]
    failed_subjects=[]
    can_register=False

    if latest_summer:
        summer_id=latest_summer['summer_semesters_id']
        selected_subjects=StudentModel.get_selected_summer_subjects(student_id, summer_id)
        failed_subjects=StudentModel.get_eligible_summer_failed_subjects(student_id)
        if (failed_subjects and
            len(selected_subjects) < len(failed_subjects) and
            latest_summer.get('status') == 'Open'):
            can_register = True

    return render_template('summer_semester.html',
                           student=student,
                           selected=selected_subjects,
                           can_register=can_register,
                           failed_count=len(failed_subjects),
                           latest_summer=latest_summer,
                           summer_closed=False)

   
    
   


@student.route("/summer_subjects", methods=["GET"])
@student_required
def summer_subjects():
    student_id = session.get("student_id")  
    latest_summer = StudentModel.get_latest_summer_semester()
    
    if not latest_summer:
        flash("No active summer semester found.", "warning")
        return redirect(url_for('student.summer_semester'))

    summer_semester_id = latest_summer['summer_semesters_id']
    failed_subjects = StudentModel.get_eligible_summer_failed_subjects(student_id)
    selected_subjects = StudentModel.get_selected_summer_subjects(student_id, summer_semester_id)
    selected_ids = [s['course_id'] for s in selected_subjects]
    available_subjects = [sub for sub in failed_subjects if sub['course_id'] not in selected_ids]
    return render_template("summer_subjects.html", subjects=available_subjects)


@student.route("/select_summer_subject/<int:subject_id>", methods=["POST"])
@student_required
def select_summer_subject(subject_id):
    student_id = session.get('student_id')
    summer_semester = StudentModel.get_latest_summer_semester()
    
    if not summer_semester:
        flash("No summer semester available.", "warning")
        return redirect(url_for("student.summer_semester"))

    StudentModel.add_summer_subject(student_id, subject_id, summer_semester['summer_semesters_id'])
    flash("Subject added for summer semester.", "success")
    return redirect(url_for("student.summer_semester"))



@student.route("/delete_summer_subject/<int:subject_id>", methods=["POST"])
@student_required
def delete_summer_subject(subject_id):
    student_id = session.get('student_id')
    summer_semester = StudentModel.get_latest_summer_semester()

    if summer_semester:
        StudentModel.delete_summer_subject(student_id, subject_id, summer_semester['summer_semesters_id'])
        flash("Subject removed from summer semester.", "success")
    
    return redirect(url_for("student.summer_semester"))


@student.route('/student_fyp', methods=['GET'])
@student_required
def student_fyp():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))
    
    student_id=session.get('student_id')
    student_obj=StudentModel.get_student_by_id(student_id)
    fyp_project=StudentModel.get_fyp_project(student_id)
    messages_list=[]
    teacher_details=None
    if fyp_project:
        messages_list=StudentModel.get_fyp_messages(fyp_project['fyp_id'])
        teacher_details=StudentModel.get_teacher_full_details(fyp_project['teacher_id'])

    all_teachers=StudentModel.get_all_teachers()    
    
    return render_template('student_fyp.html', 
                           student=student_obj, 
                           fyp=fyp_project, 
                           messages=messages_list,teacher=teacher_details,all_teachers=all_teachers)



@student.route('/submit_fyp', methods=['POST'])
@student_required
def submit_fyp():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))

    student_id=session.get('student_id')
    if not student_id:
        return redirect(url_for('student.student_login'))

    upload_folder=os.path.join(current_app.root_path, 'static', 'uploads', 'students_uploads', 'students_fyp_proposal')
    
    
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder, exist_ok=True)


    title=request.form.get('project_title')
    description=request.form.get('description')
    file=request.files.get('proposal_file')
    db_file_path=None

    if file and file.filename != '':
        if not allowed_file(file.filename):
            flash('Only PDF files are allowed.', 'danger')
            return redirect(request.url)
    
    filename=secure_filename(file.filename)
    unique_name=f"SID_{student_id}_{filename}"
    file.save(os.path.join(upload_folder, unique_name))
    db_file_path=f"uploads/students_uploads/students_fyp_proposal/{unique_name}"

    try:
        
        StudentModel.insert_fyp_proposal(student_id,title,description,None,db_file_path)
        flash('FYP Proposal Submitted Successfully!', 'success')
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')

    return redirect(url_for('student.student_fyp'))



@student.route('/send_fyp_message/<int:fyp_id>', methods=['POST'])
@login_required
def send_fyp_message(fyp_id):
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))

    student_id=session.get('student_id')
    fyp=StudentModel.get_fyp_by_id_and_student(fyp_id, student_id)
    if not fyp:
        flash('Unauthorized access.', 'danger')
        return redirect(url_for('student.student_fyp'))

    message_text=request.form.get('message')
    if message_text and message_text.strip():
        StudentModel.insert_fyp_message(fyp_id, student_id,'student',message_text)
        
    return redirect(url_for('student.student_fyp'))



@student.route('/update_fyp', methods=['POST'])
@student_required
def update_fyp():
    if session.get('role') != 'student':
        return redirect(url_for('main_view'))

    student_id=session.get('student_id')
    title=request.form.get('project_title')
    file=request.files.get('proposal_file')
    db_file_path=None 
    
    upload_folder=os.path.join(current_app.root_path, 'static', 'uploads', 'students_uploads', 'students_fyp_proposal')
    
    if file and file.filename != '':
        if not allowed_file(file.filename):
            flash('Only PDF files are allowed.', 'danger')
            return redirect(request.url)
    
    filename=secure_filename(file.filename)
    unique_name=f"SID_{student_id}_{filename}"
    file.save(os.path.join(upload_folder, unique_name))
    db_file_path = f"uploads/students_uploads/students_fyp_proposal/{unique_name}"
    
    
    StudentModel.update_fyp_data(student_id,title,db_file_path)
    flash('FYP Project updated successfully!', 'success')
    return redirect(url_for('student.student_fyp'))



@student.route('/upload_submission', methods=['POST'])
@student_required
def upload_submission():
    student_id = session.get('student_id')
    course_id = request.form.get('course_id')
    section_id = request.form.get('section_id')
    sub_type = request.form.get('type') 
    file = request.files.get('file')

    if file and file.filename != '':
        if sub_type == 'assignment':
            folder_name = 'students_assignments'
        else:
            folder_name = 'students_quizes'
            
        upload_path = os.path.join(current_app.root_path, 'static', 'uploads', 'students_uploads', folder_name)
        os.makedirs(upload_path, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = secure_filename(f"SID{student_id}_{timestamp}_{file.filename}")
        file.save(os.path.join(upload_path, filename))
        db_file_path = f"uploads/students_uploads/{folder_name}/{filename}"
        StudentModel.insert_submission(student_id, course_id, section_id, db_file_path, sub_type)
        
        flash(f"{sub_type.capitalize()} uploaded successfully!", "success")
    else:
        flash("File upload failed. No file selected.", "danger")

    return redirect(url_for('student.my_submissions'))



@student.route('/my_submissions')
@student_required
def my_submissions():
    student_id = session.get('student_id')
    courses = StudentModel.get_enrolled_courses_by_student_id(student_id)
    if not courses:
        return render_template('my_submissions.html', schedule=[], message="No courses enrolled.")

    course_ids = [c['course_id'] for c in courses]
    schedule = StudentModel.get_course_schedule_for_enrolled_sections(course_ids, student_id)
    
    course_data = StudentModel.get_course_details_by_ids(course_ids)
    course_names = {c['course_id']: c['course_name'] for c in course_data}
    for s in schedule:
        s['course_name'] = course_names.get(s['course_id'], 'Unknown')

    submissions = StudentModel.get_student_submission_status(student_id)
    
    assignment_marks = {}
    quiz_marks = {}
    assignment_totals = {}
    quiz_totals = {}

    for sub in submissions:
        cid = int(sub['course_id'])
    
        if sub['submission_type'] == 'assignment':
            assignment_marks[cid] = sub['marks']
            assignment_totals[cid] = sub['total_marks']
        elif sub['submission_type'] == 'quiz':
            quiz_marks[cid] = sub['marks']
            quiz_totals[cid] = sub['total_marks']


    uploaded_assignments = list(assignment_marks.keys())
    uploaded_quizzes = list(quiz_marks.keys())

    return render_template('my_submissions.html', 
                           schedule=schedule, 
                           uploaded_assignments=uploaded_assignments,
                           uploaded_quizzes=uploaded_quizzes,
                           assignment_marks=assignment_marks,
                           quiz_marks=quiz_marks,
                           assignment_totals=assignment_totals,
                           quiz_totals=quiz_totals
                           )


                           
