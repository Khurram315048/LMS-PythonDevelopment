from flask import Blueprint, render_template, request, redirect, url_for, session, flash, abort, current_app
from utils.auth import login_required,admin_required
from werkzeug.security import check_password_hash ,generate_password_hash
from werkzeug.utils import secure_filename
import os
from datetime import datetime
import MySQLdb.cursors
from utils.db import mysql 

admin=Blueprint('admin', __name__, template_folder='admin_views')


@admin.route('/admin_login', methods=['GET','POST'])
def admin_login():
    cursor=mysql.connection.cursor()
    if request.method=='POST':
        email=request.form['email']
        password=request.form['password']
        remember='remember_me' in request.form

        cursor.execute('SELECT * FROM users WHERE email=%s',(email,))
        admin_details=cursor.fetchone()

        if admin_details and check_password_hash(admin_details['password'],password):
            cursor.execute('SELECT * FROM admins WHERE email=%s',(email,))
            admin_data=cursor.fetchone()

            
            if not admin_data:
                flash('Access denied. You are not an admin.', 'danger')
                return render_template('admin_login.html')

            session['user_id']=admin_details['user_id']
            session['role']='admin'
            session['admin_id']=admin_data['admin_id']
            session.permanent=remember
            return redirect(url_for('admin.admin_dashboard'))
        else:
            flash('Invalid email or password.', 'danger')
            return render_template('admin_login.html')
    return render_template('admin_login.html')  
    

@admin.route('/admin_dashboard', methods=['GET', 'POST'])
@admin_required
def admin_dashboard():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT COUNT(*) AS total_students FROM students WHERE is_deleted=0')
    students=cursor.fetchone()['total_students']
    cursor.execute('SELECT COUNT(*) AS total_teachers FROM teachers WHERE is_deleted=0')
    teachers=cursor.fetchone()['total_teachers']
    cursor.execute('SELECT COUNT(*) AS pending_fee FROM student_fees WHERE fee_status=%s',("due",))
    pending=cursor.fetchone()['pending_fee']
    cursor.execute('SELECT COUNT(*) AS total_courses FROM courses WHERE is_deleted=0')
    courses_count=cursor.fetchone()['total_courses']
    cursor.execute('SELECT COUNT(*) AS total_fyp FROM fyp_groups WHERE is_deleted=0')
    fyp_count=cursor.fetchone()['total_fyp']
    cursor.execute('SELECT COUNT(*) AS total_complaints FROM complaint_suggestion')
    complaints_count=cursor.fetchone()['total_complaints']
    return render_template(
        'admin_dashboard.html',
        students_count=students,
        teachers_count=teachers,complaints_count=complaints_count,
        pending_count=pending,courses_count=courses_count,fyp_count=fyp_count)


@admin.route('/admin_profile', methods=['GET', 'POST'])
@admin_required
def admin_profile():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    admin_id=session.get('admin_id')
    
    cursor.execute('SELECT * FROM admins WHERE admin_id=%s', (admin_id,))
    admin_data=cursor.fetchone()
    if request.method=='POST':
        return redirect(url_for('admin.admin_edit'))
    
    return render_template('admin_profile.html', admin=admin_data)


@admin.route('/admin_edit', methods=['GET', 'POST'])
@admin_required
def admin_edit():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    id=session.get('admin_id')

    if request.method=='POST':
        email=request.form['email']
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        contact=request.form['contact']

        cursor.execute('''
            UPDATE admins 
            SET email=%s, first_name=%s, last_name=%s, contact=%s 
            WHERE admin_id=%s
        ''', (email,first_name,last_name,contact, id))
        
        mysql.connection.commit()
        flash("Profile updated successfully!", "success")
        return redirect(url_for('admin.admin_profile'))

    cursor.execute('SELECT * FROM admins WHERE admin_id=%s', (id,))
    admin_data = cursor.fetchone()
    return render_template('admin_edit.html', admin=admin_data)


@admin.route('/system_settings',methods=['GET','POST'])
@admin_required
def system_settings():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM system_settings')
    settings=cursor.fetchall()
    return render_template('system_settings.html',settings=settings)    
    


@admin.route('/edit_settings', methods=['GET', 'POST'])
@admin_required
def edit_settings():
    cursor=mysql.connection.cursor()
    if request.method=='POST':
        setting_key=request.form.get('setting_key')
        new_value=request.form.get('setting_value')
        cursor.execute('UPDATE system_settings SET setting_value=%s WHERE setting_key=%s', (new_value, setting_key))
        mysql.connection.commit()
        cursor.close()
        flash(f"Setting '{setting_key}' updated successfully!", "success")
    return redirect(url_for('admin.system_settings'))   


@admin.route('/complaints', methods=['GET', 'POST'])
@admin_required
def complaints():
    cursor=mysql.connection.cursor()
    cursor.execute('''
        SELECT cs.*, u.email
        FROM complaint_suggestion cs
        JOIN users u ON cs.user_id=u.user_id
    ''')
    complaints=cursor.fetchall()
    return render_template('complaints.html', complaints=complaints)



@admin.route('/solve_complaint',methods=['POST'])
@admin_required
def solve_complaint():
    cursor=mysql.connection.cursor()
    complt_sugst_id=request.form.get('complt_sugst_id') 
    cursor.execute('UPDATE complaint_suggestion SET is_status=%s WHERE complt_sugst_id=%s',("Solved",complt_sugst_id))
    mysql.connection.commit()
    flash('Complaint marked as solved.', 'success')
    return redirect(url_for('admin.complaints'))  



@admin.route('/system_controls',methods=['GET','POST'])
@admin_required
def system_controls():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM semester WHERE is_deleted=%s',(0,))
    semesters=cursor.fetchall()
    return render_template('system_controls.html',semesters=semesters)



@admin.route('/add_semester',methods=['GET','POST'])
@admin_required
def add_semester():
    cursor=mysql.connection.cursor()
    if request.method=='POST':
        sem_name=request.form['name']
        sem_year=request.form['year']
        sm_start=request.form['start_date']
        sm_end=request.form['end_date']
        cursor.execute('INSERT INTO semester(name,year,start_date,end_date,created_at) VALUES'
        '(%s,%s,%s,%s,%s)',(sem_name,sem_year,sm_start,sm_end,datetime.now()))
        mysql.connection.commit()
        flash('Semester added successfully.', 'success')
        return redirect(url_for('admin.system_controls'))
    return redirect(url_for('admin.system_controls'))



@admin.route('/edit_semester',methods=['GET','POST'])
@admin_required
def edit_semester():
    cursor=mysql.connection.cursor()
    semester_id=request.form.get('semester_id')
    if request.method=='POST':
        sem_name=request.form['name']
        sem_year=request.form['year']
        sm_start=request.form['start_date']
        sm_end=request.form['end_date']
        cursor.execute('UPDATE semester SET name=%s,year=%s,start_date=%s,end_date=%s,created_at=%s WHERE ' \
        'semester_id=%s',(sem_name,sem_year,sm_start,sm_end,datetime.now(),semester_id))
        mysql.connection.commit()
        flash('Semester Updated successfully.', 'success')
        return redirect(url_for('admin.system_controls'))
    return redirect(url_for('admin.system_controls'))



@admin.route('/delete_semester',methods=['GET','POST'])
@admin_required
def delete_semester():
    cursor=mysql.connection.cursor()
    semester_id=request.form.get('semester_id')
    if request.method=='POST':
        cursor.execute('UPDATE semester SET is_deleted=%s  WHERE semester_id=%s',(1,semester_id,))
        mysql.connection.commit()
        flash('Semester Deleted successfully.', 'success')
        return redirect(url_for('admin.system_controls'))
    return redirect(url_for('admin.system_controls'))



@admin.route('/register_student', methods=['GET','POST'])
@admin_required
def register_student():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT ss.*, p.program_name,u.email
        FROM students ss 
        JOIN programs p ON ss.program_id=p.program_id
        JOIN users u ON ss.user_id=u.user_id
                   WHERE ss.is_deleted=%s
    ''',(0,))
    students=cursor.fetchall()
    cursor.execute('SELECT * FROM programs')
    programs=cursor.fetchall()
    cursor.execute('SELECT DISTINCT admission_session FROM students WHERE admission_session IS NOT NULL')
    sessions=cursor.fetchall()
    return render_template('register_student.html',students=students,programs=programs,sessions=sessions)



@admin.route('/add_student', methods=['POST'])
@admin_required
def add_student():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method=='POST':
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        email=request.form['email']
        password=request.form['password']
        contact=request.form['contact']
        program_id=request.form['program_id']
        admission_session=request.form['admission_session']
        last_qual=request.form['last_qualification']
        admission_date=request.form['admission_date']

        cursor.execute('SELECT user_id FROM users WHERE email=%s AND is_deleted=%s', (email,0,))
        existing=cursor.fetchone()
        if existing:
            flash('Email already registered.', 'danger')
            return redirect(url_for('admin.register_student'))

        hashed_password=generate_password_hash(password)
        cursor.execute('INSERT INTO users (email,password,role_id) VALUES (%s,%s,%s)',
                    (email,hashed_password,2))
        mysql.connection.commit()
        user_id=cursor.lastrowid

        cursor.execute('''
            INSERT INTO students 
            (user_id,first_name,last_name,email,contact,program_id,admission_session,last_qualification,admission_date)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        ''', (user_id,first_name,last_name,email,contact,program_id,admission_session,last_qual,admission_date))
        mysql.connection.commit()
        flash('Student registered successfully.', 'success')
        return redirect(url_for('admin.register_student'))
    
    return redirect(url_for('admin.register_student'))


@admin.route('/delete_student',methods=['GET','POST'])
@admin_required
def delete_student():
    cursor=mysql.connection.cursor()
    student_id=request.form.get('student_id')
    if request.method=='POST':
        cursor.execute('UPDATE students SET is_deleted=%s WHERE student_id=%s',(1,student_id,))
        mysql.connection.commit()
        flash('Student Deleted successfully.', 'success')
        return redirect(url_for('admin.register_student'))
    return redirect(url_for('admin.register_student'))   



@admin.route('/update_student', methods=['POST'])
@admin_required
def update_student():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    student_id=request.form.get('student_id')
    if request.method=='POST':
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        email=request.form['email']
        contact=request.form['contact']
        program_id=request.form['program_id']
        admission_session=request.form['admission_session']
        last_qual=request.form['last_qualification']
        admission_date=request.form['admission_date']

        cursor.execute('SELECT user_id FROM students WHERE student_id=%s', (student_id,))
        student=cursor.fetchone()
        user_id=student['user_id']

        cursor.execute('''
            UPDATE  students SET first_name=%s,last_name=%s,email=%s,contact=%s,program_id=%s,admission_session=%s,
                       last_qualification=%s,admission_date=%s 
                       WHERE student_id=%s ''',(first_name,last_name,email,contact,program_id,admission_session,last_qual,admission_date,student_id))
        mysql.connection.commit()
        cursor.execute('UPDATE users SET email=%s WHERE user_id=%s',(email,user_id))
        mysql.connection.commit()
        flash('Student Updated successfully.', 'success')
        return redirect(url_for('admin.register_student'))
    
    return redirect(url_for('admin.register_student'))    


@admin.route('/manage_attendance', methods=['GET', 'POST'])
@admin_required
def manage_attendance():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    query='''
        SELECT a.attendance_id, a.attendance_date, a.attendance_status,
               s.first_name, s.last_name,
               c.course_name,
               sec.section_name
        FROM attendance a
        JOIN students s ON a.student_id=s.student_id
        JOIN student_course sc ON a.student_course_id=sc.student_course_id
        JOIN courses c ON sc.course_id=c.course_id
        JOIN course_schedule cs ON a.course_schedule_id=cs.course_schedule_id
        JOIN sections sec ON cs.section_id=sec.section_id
        WHERE  a.is_deleted=%s
    '''
    cursor.execute(query,(0,))
    attendance=cursor.fetchall()
    cursor.execute('SELECT course_id, course_name FROM courses')
    courses=cursor.fetchall()
    cursor.execute('SELECT section_id, section_name FROM sections')
    sections=cursor.fetchall()

    return render_template('manage_attendance.html',attendance=attendance,courses=courses,sections=sections,)   


@admin.route('/update_attendance', methods=['POST'])
@admin_required
def update_attendance():
    cursor=mysql.connection.cursor()
    attendance_id=request.form.get('attendance_id')
    attendance_status=request.form.get('attendance_status')
    cursor.execute('UPDATE attendance SET attendance_status=%s WHERE attendance_id=%s',
                   (attendance_status,attendance_id))
    mysql.connection.commit()
    flash('Attendance updated.', 'success')
    return redirect(url_for('admin.manage_attendance'))




@admin.route('/manage_grades', methods=['GET'])
@admin_required
def manage_grades():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    program_id=request.args.get('program_id', '')
    selected_semester=request.args.get('semester', '')

    query= '''
        SELECT sr.student_result_id, sr.student_id, sr.student_semester,
               sr.overall_gpa, sr.result_status,
               s.first_name, s.last_name
        FROM student_results sr
        JOIN students s ON sr.student_id=s.student_id
        JOIN programs p ON s.program_id=p.program_id
        WHERE 1=1
    '''
    params=[]

    if program_id:
        query += ' AND p.program_id = %s'
        params.append(program_id)
    if selected_semester:
        query += ' AND sr.student_semester = %s'
        params.append(selected_semester)

    query += ' ORDER BY sr.student_semester ASC'
    cursor.execute(query, params)
    results=cursor.fetchall()

    for result in results:
        cursor.execute('''
            SELECT srm.*, c.course_name
            FROM student_result_marks srm
            JOIN student_course sc ON srm.student_course_id = sc.student_course_id
            JOIN courses c ON sc.course_id = c.course_id
            WHERE srm.student_result_id = %s
        ''', (result['student_result_id'],))
        result['marks']=cursor.fetchall()

    cursor.execute('SELECT program_id, program_name FROM programs')
    programs=cursor.fetchall()

    return render_template('manage_grades.html',
                           results=results,
                           programs=programs,
                           selected_program=int(program_id) if program_id else '',
                           selected_semester=selected_semester)



@admin.route('/update_result',methods=['POST'])
@admin_required
def update_result():
    cursor=mysql.connection.cursor()
    student_result_id=request.form.get('student_result_id')
    overall_gpa=request.form.get('overall_gpa')
    result_status=request.form.get('result_status')
    cursor.execute('''
        UPDATE student_results SET overall_gpa=%s, result_status=%s
        WHERE student_result_id=%s
    ''', (overall_gpa, result_status, student_result_id))
    mysql.connection.commit()
    flash('Result updated successfully.', 'success')
    return redirect(url_for('admin.manage_grades'))    



@admin.route('/fee_management', methods=['GET'])
@admin_required
def fee_management():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    query='''
        SELECT sf.*, p.program_name, s.first_name, s.last_name
        FROM student_fees sf
        JOIN students s ON sf.student_id=s.student_id
        JOIN programs p ON sf.program_id=p.program_id
        WHERE 1=1
    '''
    cursor.execute(query)
    fees=cursor.fetchall()

    cursor.execute('SELECT program_id,program_name FROM programs')
    programs=cursor.fetchall()

    cursor.execute('SELECT student_id,first_name,last_name FROM students WHERE is_deleted=0')
    students=cursor.fetchall()

    return render_template('fee_management.html',fees=fees,programs=programs,students=students)



@admin.route('/update_fee_status', methods=['POST'])
@admin_required
def update_fee_status():
    cursor=mysql.connection.cursor()
    student_fees_id=request.form.get('student_fees_id')
    fee_status=request.form.get('fee_status')
    cursor.execute('UPDATE student_fees SET fee_status=%s WHERE student_fees_id=%s',
                   (fee_status, student_fees_id))
    mysql.connection.commit()
    flash('Fee status updated.', 'success')
    return redirect(url_for('admin.fee_management'))


@admin.route('/add_fee_record', methods=['POST'])
@admin_required
def add_fee_record():
    cursor=mysql.connection.cursor()
    student_id=request.form.get('student_id')
    program_id=request.form.get('program_id')
    fee_amount=request.form.get('fee_amount')
    fee_month=request.form.get('fee_month')
    fee_status=request.form.get('fee_status')
    cursor.execute('''
        INSERT INTO student_fees (student_id,program_id,fee_amount,fee_month,fee_status,update_date)
        VALUES (%s,%s,%s,%s,%s, NOW())
    ''', (student_id,program_id,fee_amount,fee_month,fee_status))
    mysql.connection.commit()
    flash('Fee record added.', 'success')
    return redirect(url_for('admin.fee_management'))



@admin.route('/course_registration', methods=['GET'])
@admin_required
def course_registration():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT sc.student_course_id, s.first_name, s.last_name, s.student_id,
               c.course_name, p.program_name
        FROM student_course sc
        JOIN students s ON sc.student_id=s.student_id
        JOIN courses c ON sc.course_id=c.course_id
        JOIN programs p ON s.program_id=p.program_id
        WHERE sc.is_deleted=%s
    ''',(0,))
    enrollments=cursor.fetchall()

    cursor.execute('SELECT student_id, first_name, last_name FROM students WHERE is_deleted=%s',(0,))
    students=cursor.fetchall()

    cursor.execute('SELECT course_id,course_name FROM courses WHERE is_deleted=%s',(0,))
    courses=cursor.fetchall()
    cursor.execute('SELECT section_id, section_name, semester, course_id FROM sections')
    sections=cursor.fetchall()

    return render_template('course_registration.html',
                           enrollments=enrollments,
                           students=students,
                           courses=courses,sections=sections)


@admin.route('/enroll_student', methods=['POST'])
@admin_required
def enroll_student():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    student_id=request.form.get('student_id')
    course_id=request.form.get('course_id')
    section_id=request.form.get('section_id')

    if not section_id:
        flash('Please select a section.', 'danger')
        return redirect(url_for('admin.course_registration'))

    
    cursor.execute(
        'SELECT * FROM student_course WHERE student_id=%s AND course_id=%s AND is_deleted=%s',
        (student_id,course_id, 0)
    )
    if cursor.fetchone():
        flash('Student is already enrolled in this course.', 'warning')
        return redirect(url_for('admin.course_registration'))


    cursor.execute(
        'INSERT INTO student_course (student_id,course_id) VALUES (%s,%s)',
        (student_id,course_id)
    )
    mysql.connection.commit()

    cursor.execute(
        'SELECT * FROM student_section WHERE student_id=%s AND section_id=%s AND is_deleted=0',
        (student_id,section_id)
    )
    active_record=cursor.fetchone()

    if active_record:
        pass
    else:
        
        cursor.execute(
            'SELECT * FROM student_section WHERE student_id=%s AND section_id=%s AND is_deleted=1',
            (student_id,section_id)
        )
        deleted_record=cursor.fetchone()

        if deleted_record:
            cursor.execute(
                'UPDATE student_section SET is_deleted=0 WHERE student_id=%s AND section_id=%s',
                (student_id, section_id)
            )
        else:
            cursor.execute(
                'INSERT INTO student_section (student_id,section_id) VALUES (%s,%s)',
                (student_id,section_id)
            )
        mysql.connection.commit()

    flash('Student enrolled successfully in course and section.', 'success')
    return redirect(url_for('admin.course_registration'))


@admin.route('/remove_enrollment', methods=['POST'])
@admin_required
def remove_enrollment():
    cursor=mysql.connection.cursor()
    student_course_id=request.form.get('student_course_id')

    cursor.execute(
        'SELECT student_id, course_id FROM student_course WHERE student_course_id=%s',
        (student_course_id,)
    )
    record=cursor.fetchone()
    cursor.execute('UPDATE student_course SET is_deleted=%s WHERE student_course_id=%s',(1,student_course_id,))
    mysql.connection.commit()
    if record:
        cursor.execute('''
            UPDATE student_section 
            SET is_deleted=1
            WHERE student_id=%s 
            AND section_id IN (
            SELECT section_id FROM sections WHERE course_id=%s
            )
            ''', (record['student_id'], record['course_id']))
    mysql.connection.commit()

    flash('Enrollment removed.','danger')
    return redirect(url_for('admin.course_registration'))


@admin.route('/stSemester_freeze', methods=['GET'])
@admin_required
def stSemester_freeze():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT sfr.freeze_id,sfr.semester,sfr.reason,sfr.status,sfr.applied_date,
               s.first_name,s.last_name,s.student_id
        FROM semester_freeze_students sfr
        JOIN students s ON sfr.student_id=s.student_id
    ''')
    freeze_requests=cursor.fetchall()
    return render_template('stSemester_freeze.html', freeze_requests=freeze_requests)


@admin.route('/approve_request/<int:freeze_id>', methods=['POST'])
@admin_required
def approve_request(freeze_id):
    cursor=mysql.connection.cursor()
    cursor.execute('UPDATE semester_freeze_students SET status=%s WHERE freeze_id=%s',
                   ('Approved', freeze_id))
    mysql.connection.commit()
    flash('Request approved.', 'success')
    return redirect(url_for('admin.stSemester_freeze'))


@admin.route('/reject_request/<int:freeze_id>', methods=['POST'])
@admin_required
def reject_request(freeze_id):
    cursor=mysql.connection.cursor()
    cursor.execute('UPDATE semester_freeze_students SET status=%s WHERE freeze_id=%s',
                   ('Rejected', freeze_id))
    mysql.connection.commit()
    flash('Request rejected.', 'success')
    return redirect(url_for('admin.stSemester_freeze'))
         


@admin.route('/stSummer_semester', methods=['GET'])
@admin_required
def stSummer_semester():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM summer_semesters ORDER BY year DESC, summer_semesters_id DESC')
    summer_semesters=cursor.fetchall()

    for sem in summer_semesters:
        cursor.execute('''
            SELECT s.first_name,s.last_name,c.course_name,sr.registration_date
            FROM summer_registration sr
            JOIN students s ON sr.student_id=s.student_id
            JOIN courses c ON sr.course_id=c.course_id
            WHERE sr.summer_semesters_id=%s
        ''', (sem['summer_semesters_id'],))
        sem['registrations']=cursor.fetchall()


    cursor.execute('SELECT semester_id, name, year FROM semester ORDER BY year DESC')
    semesters=cursor.fetchall()

    return render_template('stSummer_semester.html',
                           summer_semesters=summer_semesters,
                           semesters=semesters)


@admin.route('/add_summer_semester',methods=['POST'])
@admin_required
def add_summer_semester():
    cursor=mysql.connection.cursor()
    name=request.form.get('name')
    year=request.form.get('year')
    start_date=request.form.get('start_date')
    end_date=request.form.get('end_date')
    status=request.form.get('status')
    previous_semester_id=request.form.get('previous_semester_id') or None
    cursor.execute('''
        INSERT INTO summer_semesters (name,year,start_date,end_date,status,previous_semester_id)
        VALUES (%s, %s, %s, %s, %s, %s)
    ''', (name,year,start_date,end_date,status,previous_semester_id))
    mysql.connection.commit()
    flash('Summer semester added successfully.', 'success')
    return redirect(url_for('admin.stSummer_semester'))


@admin.route('/delete_summer_semester', methods=['POST'])
@admin_required
def delete_summer_semester():
    cursor=mysql.connection.cursor()
    summer_semesters_id=request.form.get('summer_semesters_id')
    cursor.execute('DELETE FROM summer_semesters WHERE summer_semesters_id=%s', (summer_semesters_id,))
    mysql.connection.commit()
    flash('Summer semester deleted.', 'danger')
    return redirect(url_for('admin.stSummer_semester'))       


@admin.route('/view_teachers', methods=['GET', 'POST'])
@admin_required
def view_teachers():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT teacher_id,first_name,last_name,email, 
               contact_num,qualification,joining_date
        FROM teachers
        WHERE is_deleted=%s
    ''', (0,))
    teachers=cursor.fetchall()
    for teacher in teachers:
        cursor.execute('''
            SELECT c.course_name
            FROM teacher_course tc
            JOIN courses c ON tc.course_id=c.course_id
            WHERE tc.teacher_id=%s AND tc.is_deleted=%s
        ''', (teacher['teacher_id'], 0))
        teacher['courses']=cursor.fetchall()
        
    cursor.execute('SELECT course_id,course_name FROM courses WHERE is_deleted=%s',(0,))
    all_courses=cursor.fetchall()
    cursor.close()
    return render_template('view_teachers.html',teachers=teachers,all_courses=all_courses)


@admin.route('/delete_teacher',methods=['GET','POST'])
@admin_required
def delete_teacher():
    cursor=mysql.connection.cursor()
    teacher_id=request.form.get('teacher_id')
    teacher_email=request.form.get('email')
    cursor.execute('UPDATE teachers SET is_deleted=%s WHERE teacher_id=%s',(1,teacher_id))
    mysql.connection.commit()
    cursor.execute('UPDATE users SET is_deleted=%s WHERE email=%s',(1,teacher_email))
    mysql.connection.commit()
    return redirect(url_for('admin.view_teachers'))


@admin.route('/add_teacher', methods=['GET', 'POST'])
@admin_required
def add_teacher():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method=='POST':
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        email=request.form['email']
        password=request.form['password']
        contact_num=request.form['contact_num']
        qualification=request.form['qualification']
        joining_date=request.form['joining_date']
        course_ids=request.form.getlist('course_ids') 

        cursor.execute('SELECT email FROM teachers WHERE email=%s AND is_deleted=0',(email,))
        if cursor.fetchone():
            flash('Teacher with this email already exists.', 'warning')
            return redirect(url_for('admin.view_teachers'))

        hashed_password=generate_password_hash(password)
        cursor.execute('INSERT INTO users(email,password,role_id) VALUES(%s,%s,%s)',
                       (email,hashed_password,1))
        mysql.connection.commit()
        user_id=cursor.lastrowid  

        cursor.execute('''
            INSERT INTO teachers(user_id,first_name,last_name,email,contact_num,qualification,joining_date)
            VALUES(%s,%s,%s,%s,%s,%s,%s)
        ''', (user_id,first_name,last_name,email,contact_num,qualification,joining_date))
        mysql.connection.commit()
        teacher_id=cursor.lastrowid  

        for cid in course_ids:
            cursor.execute('INSERT INTO teacher_course(teacher_id,course_id) VALUES(%s,%s)',
                           (teacher_id,cid))
        mysql.connection.commit()

        cursor.close()
        flash('Teacher added successfully.', 'success')
        return redirect(url_for('admin.view_teachers'))

    return redirect(url_for('admin.view_teachers'))




@admin.route('/edit_teacher', methods=['GET', 'POST'])
@admin_required
def edit_teacher():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    teacher_id=request.form.get('teacher_id')
    if request.method=='POST':
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        email=request.form['email']
        contact_num=request.form['contact_num']
        qualification=request.form['qualification']
        joining_date=request.form['joining_date']
        course_ids=request.form.getlist('course_ids') 

        cursor.execute('SELECT user_id FROM teachers WHERE teacher_id=%s',(teacher_id,))
        user_id=cursor.fetchone()['user_id']

        cursor.execute('UPDATE  users SET email=%s WHERE user_id=%s',(email,user_id))
        mysql.connection.commit()  

        cursor.execute('UPDATE teachers SET first_name=%s,last_name=%s,email=%s,contact_num=%s,qualification=%s,joining_date=%s WHERE user_id=%s',
                       (first_name,last_name,email,contact_num,qualification,joining_date,user_id))
        mysql.connection.commit()

        cursor.execute('DELETE FROM teacher_course WHERE teacher_id=%s',(teacher_id,))
        for cid in course_ids:
            cursor.execute('INSERT INTO teacher_course(teacher_id,course_id) VALUES(%s,%s)',
                           (teacher_id,cid))
        mysql.connection.commit()
        cursor.close()
        flash('Teacher Updated successfully.', 'success')
        return redirect(url_for('admin.view_teachers'))

    return redirect(url_for('admin.view_teachers'))



@admin.route('/salary_record',methods=['GET'])
@admin_required
def salary_record():
    cursor=mysql.connection.cursor()

    cursor.execute("SELECT teacher_id,first_name,last_name FROM teachers WHERE is_deleted=%s",(0,))
    teachers=cursor.fetchall()

    query="""
        SELECT s.salary_id,t.first_name,t.last_name,s.month,s.year,
               s.basic_salary,s.bonus,s.deductions,
               (s.basic_salary + s.bonus - s.deductions) AS net_salary,s.status
        FROM teacher_salary s
        JOIN teachers t ON s.teacher_id=t.teacher_id
        WHERE s.is_deleted=%s
        ORDER BY s.salary_id ASC
    """
    cursor.execute(query,(0,))
    salary_records=cursor.fetchall()
    cursor.close()

    return render_template('salary_record.html',teachers=teachers,salary_records=salary_records)


@admin.route('/add_record',methods=['POST'])
@admin_required
def add_record():
    cursor=mysql.connection.cursor()

    teacher_id=request.form.get('teacher_id')
    month=request.form['month']
    year=request.form['year']
    basic_sal=request.form['basic_salary']
    bonus=request.form['bonus']
    deduct=request.form['deductions']
    status=request.form['status']

    cursor.execute('SELECT salary_id FROM teacher_salary WHERE teacher_id=%s AND month=%s AND year=%s',
                   (teacher_id,month,year))
    if cursor.fetchone():
        flash('Salary Record Already Exists','danger')
        return redirect(url_for('admin.salary_record'))

    cursor.execute('''INSERT INTO teacher_salary(teacher_id,month,year,basic_salary,bonus,deductions,status)
                   VALUES(%s,%s,%s,%s,%s,%s,%s)''',(teacher_id,month,year,basic_sal,bonus,deduct,status))
    mysql.connection.commit()
    cursor.close()
    flash('Record Added Successfully', 'success')
    return redirect(url_for('admin.salary_record'))
   

@admin.route('/update_salary',methods=['POST'])
@admin_required
def update_salary():
    cursor=mysql.connection.cursor()
    salary_id=request.form.get('salary_id')

    basic_sal=request.form['basic_salary']
    bonus=request.form['bonus']
    deduct=request.form['deductions']
    status=request.form['status']

    cursor.execute('UPDATE teacher_salary SET basic_salary=%s,bonus=%s,deductions=%s,status=%s WHERE salary_id=%s',
    (basic_sal,bonus,deduct,status,salary_id))
    mysql.connection.commit()
    cursor.close()
    flash('Record Updated Successfully','success')
    return redirect(url_for('admin.salary_record'))


@admin.route('/delete_salary',methods=['POST'])
@admin_required
def delete_salary():
    cursor=mysql.connection.cursor()

    salary_id=request.form.get('salary_id')
    cursor.execute('UPDATE teacher_salary SET is_deleted=%s WHERE salary_id=%s',(1,salary_id))
    mysql.connection.commit()
    flash('Record Deleted Successfully','success')
    return redirect(url_for('admin.salary_record'))




@admin.route('/assign_classes', methods=['GET'])
@admin_required
def assign_classes():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT tc.teacher_course_id,t.first_name,t.last_name,
               c.course_name,c.credit_hours,p.program_name
        FROM teacher_course tc
        JOIN teachers t ON tc.teacher_id=t.teacher_id
        JOIN courses c ON tc.course_id=c.course_id
        JOIN programs p ON c.program_id=p.program_id
        WHERE tc.is_deleted=0 AND t.is_deleted=0 AND c.is_deleted=0
    ''')
    assignments=cursor.fetchall()

    cursor.execute('SELECT teacher_id,first_name,last_name FROM teachers WHERE is_deleted=0')
    teachers=cursor.fetchall()

    cursor.execute('''
        SELECT c.course_id,c.course_name,p.program_name
        FROM courses c
        JOIN programs p ON c.program_id=p.program_id
        WHERE c.is_deleted=0
    ''')
    courses=cursor.fetchall()

    cursor.close()
    return render_template('assign_classes.html',
                           assignments=assignments,
                           teachers=teachers,
                           courses=courses)


@admin.route('/assign_course',methods=['GET','POST'])
@admin_required
def assign_course():
    cursor=mysql.connection.cursor()
    if request.method=='POST':
        teacher_id=request.form.get('teacher_id')
        course_id=request.form.get('course_id')

        cursor.execute('INSERT INTO teacher_course (course_id,teacher_id) VALUES (%s,%s)',(course_id,teacher_id))
        mysql.connection.commit()
        cursor.close()
        return redirect(url_for('admin.assign_classes'))

    return redirect(url_for('admin.assign_classes'))    


@admin.route('/delete_course',methods=['GET','POST'])
@admin_required
def delete_course():
    cursor=mysql.connection.cursor()
    teacher_course_id=request.form.get('teacher_course_id')
    if request.method=='POST':
        cursor.execute('UPDATE teacher_course SET is_deleted=%s  WHERE teacher_course_id=%s',(1,teacher_course_id,))
        mysql.connection.commit()
        flash('Course Deleted successfully.', 'success')
        return redirect(url_for('admin.assign_classes'))
    
    return redirect(url_for('admin.assign_classes'))



@admin.route('/course_attendance', methods=['GET'])
@admin_required
def course_attendance():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    cursor.execute('''
        SELECT cal.log_id,cal.attendance_date,cal.total_students,cal.total_present,cal.total_absent,
            t.first_name, t.last_name,c.course_name,cs.day_of_week
        FROM course_attendance_log cal
        JOIN teachers t  ON cal.teacher_id=t.teacher_id
        JOIN courses c   ON cal.course_id=c.course_id
        JOIN course_schedule cs ON cal.course_schedule_id=cs.course_schedule_id
        WHERE cal.is_deleted=0
    ''')
    attendance_records=cursor.fetchall()
    cursor.execute('SELECT teacher_id,first_name,last_name FROM teachers WHERE is_deleted=0')
    teachers=cursor.fetchall()

    cursor.execute('SELECT course_id,course_name FROM courses WHERE is_deleted=0')
    courses=cursor.fetchall()

    cursor.execute('''
        SELECT s.section_id,s.section_name,s.semester,c.course_name
        FROM sections s
        JOIN courses c  ON s.course_id=c.course_id
        WHERE s.is_deleted=0
    ''')
    sections=cursor.fetchall()

    return render_template('course_attendance.html',
                           attendance_records=attendance_records,
                           teachers=teachers,
                           courses=courses,sections=sections)



@admin.route('/mark_course_attendance', methods=['POST'])
@admin_required
def mark_course_attendance():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    teacher_id=request.form.get('teacher_id')
    course_id=request.form.get('course_id')
    section_id=request.form.get('section_id')
    attendance_date=request.form.get('attendance_date')
    semester=request.form.get('semester')
    total_present=int(request.form.get('total_present', 0))
    total_absent=int(request.form.get('total_absent', 0))
    total_students=total_present + total_absent

    cursor.execute('''
            SELECT cs.course_schedule_id, s.semester 
            FROM course_schedule cs
            JOIN sections s ON cs.section_id=s.section_id
            WHERE cs.section_id=%s LIMIT 1
        ''',(section_id,))
    schedule=cursor.fetchone()

    if not schedule:
        flash('No schedule found for this section.', 'danger')
        return redirect(url_for('admin.course_attendance'))

    course_schedule_id=schedule['course_schedule_id']
    semester=schedule['semester']

    cursor.execute('''
        INSERT INTO course_attendance_log
        (teacher_id,course_id,course_schedule_id,attendance_date,semester,total_students,total_present,total_absent)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        ''', (teacher_id,course_id,course_schedule_id,attendance_date,
            semester,total_students,total_present,total_absent))
    flash('Attendance record added.', 'success')

    mysql.connection.commit()
    return redirect(url_for('admin.course_attendance'))



@admin.route('/class_timetable', methods=['GET'])
@admin_required
def class_timetable():
    cursor=mysql.connection.cursor()
    cursor.execute("""
        SELECT cs.course_schedule_id,cs.day_of_week,cs.start_time,cs.end_time,cs.location,
               c.course_name,s.section_name
        FROM course_schedule cs
        JOIN courses c ON cs.course_id=c.course_id
        JOIN sections s ON cs.section_id=s.section_id
        WHERE cs.is_deleted=%s
    """,(0,))
    schedules=cursor.fetchall()
    cursor.execute('SELECT course_id,course_name FROM courses')
    courses=cursor.fetchall()
    cursor.execute('SELECT section_id,section_name FROM sections')
    sections=cursor.fetchall()

    return render_template('class_timetable.html',schedules=schedules,courses=courses,sections=sections)   



@admin.route('/add_schedule',methods=['POST'])
@admin_required
def add_schedule():
    cursor=mysql.connection.cursor()

    course_id=request.form.get('course_id')
    section_id=request.form.get('section_id')
    day_of_week=request.form['day_of_week']
    start_time=request.form['start_time']
    end_time=request.form['end_time']
    location=request.form['location']

    cursor.execute('SELECT course_id FROM course_schedule WHERE course_id=%s',(course_id,))
    exist=cursor.fetchone()
    if exist:
        flash('Schedule Already Exist','danger')
        return redirect(url_for('admin.class_timetable'))
    
    cursor.execute('''INSERT INTO course_schedule(day_of_week,start_time,end_time,location,course_id,section_id) 
                   VALUES (%s,%s,%s,%s,%s,%s)''',(day_of_week,start_time,end_time,location,course_id,section_id))
    mysql.connection.commit()
    cursor.close()
    flash('Schedule Added to the System','success')
    return redirect(url_for('admin.class_timetable'))



@admin.route('/update_schedule',methods=['POST'])
@admin_required
def update_schedule():
    cursor=mysql.connection.cursor()
    course_schedule_id=request.form.get('course_schedule_id')
    day_of_week=request.form['day_of_week']
    start_time=request.form['start_time']
    end_time=request.form['end_time']
    location=request.form['location']

    cursor.execute('''
    UPDATE course_schedule SET day_of_week=%s,start_time=%s,end_time=%s,location=%s WHERE course_schedule_id=%s
    ''',(day_of_week,start_time,end_time,location,course_schedule_id))
    mysql.connection.commit()
    cursor.close()
    flash('Schedule Updated Successfully','success')
    return redirect(url_for('admin.class_timetable'))


@admin.route('/delete_schedule',methods=['POST'])
@admin_required
def delete_schedule():
    cursor=mysql.connection.cursor()
    course_schedule_id=request.form.get('course_schedule_id')
    cursor.execute('UPDATE course_schedule SET is_deleted=%s WHERE course_schedule_id=%s',(1,course_schedule_id))
    mysql.connection.commit()
    cursor.close()
    flash('Schedule Deleted Successfully','success')
    return redirect(url_for('admin.class_timetable'))    



@admin.route('/exam_dates',methods=['GET'])
@admin_required
def exam_dates():
    return render_template('exam_dates.html')


@admin.route('/get_proposals',methods=['GET'])
@admin_required
def get_proposals():
    cursor=mysql.connection.cursor()
    cursor.execute("""
        SELECT fy.fyp_id,fy.project_title,fy.description,fy.`status`,fy.last_submission,fy.created_at,
           fy.student_id,fy.teacher_id,
           CONCAT(s.first_name,' ',s.last_name) AS student_name,
           s.email AS student_email, s.contact AS student_contact,
           p.program_name AS program,
           sec.semester
        FROM fyp_groups fy
        JOIN students s ON fy.student_id=s.student_id
        JOIN programs p ON s.program_id=p.program_id
        LEFT JOIN student_section ss ON s.student_id=ss.student_id AND ss.is_deleted=0
        LEFT JOIN sections sec ON ss.section_id=sec.section_id
        WHERE fy.is_deleted=%s AND fy.`status`='Pending Approval'
        """, (0,))
    fyp_groups=cursor.fetchall()
    cursor.execute('SELECT teacher_id,first_name,last_name FROM teachers WHERE is_deleted=%s',(0,))
    teachers=cursor.fetchall()
    
    return render_template('get_proposals.html',fyp_groups=fyp_groups,teachers=teachers) 

          
@admin.route('/fyp_proposals', methods=['GET'])
@admin_required
def fyp_proposals():
    cursor=mysql.connection.cursor()

    cursor.execute("""
    SELECT fy.fyp_id, fy.project_title,fy.progress,fy.description,fy.status,fy.last_submission,fy.created_at,
           fy.student_id,fy.teacher_id,
           CONCAT(s.first_name,' ',s.last_name) AS student_name,
           s.email AS student_email, s.contact AS student_contact,
           p.program_name AS program,
           sec.semester,
           CONCAT(t.first_name,' ',t.last_name) AS teacher_name,
           t.email AS teacher_email, t.contact_num AS teacher_contact
    FROM fyp_groups fy
    JOIN students s ON fy.student_id=s.student_id
    JOIN teachers t ON fy.teacher_id=t.teacher_id
    JOIN programs p ON s.program_id=p.program_id
    LEFT JOIN student_section ss ON s.student_id=ss.student_id AND ss.is_deleted=0
    LEFT JOIN sections sec ON ss.section_id=sec.section_id
    WHERE fy.is_deleted=%s
    """,(0,))
    fyp_groups=cursor.fetchall()
    cursor.close()

    return render_template('fyp_proposals.html',fyp_groups=fyp_groups)



@admin.route('/updated_fyp',methods=['POST'])
@admin_required
def updated_fyp():
    cursor=mysql.connection.cursor()

    fyp_id=request.form.get('fyp_id')
    fyp_status=request.form['status']

    cursor.execute('UPDATE fyp_groups SET status=%s WHERE fyp_id=%s',(fyp_status,fyp_id))
    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('admin.fyp_proposals'))



@admin.route('/assign_supervisor', methods=['POST'])
@admin_required
def assign_supervisor():
    cursor=mysql.connection.cursor()
    fyp_id=request.form.get('fyp_id')
    teacher_id=request.form.get('teacher_id')

    cursor.execute("UPDATE fyp_groups SET teacher_id=%s WHERE fyp_id=%s",(teacher_id,fyp_id))
    mysql.connection.commit()
    cursor.close()
    flash('Supervisor assigned successfully.', 'success')
    return redirect(url_for('admin.fyp_proposals'))


@admin.route('/admin_notifications',methods=['GET'])
@admin_required
def admin_notifications():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT id,title,sender_role,receiver_role,status,created_at FROM notifications WHERE is_deleted=%s',(0,))
    notifications=cursor.fetchall()
    cursor.execute('SELECT course_id,course_name FROM courses WHERE is_deleted=%s',(0,))
    courses=cursor.fetchall()
    cursor.execute("""
        SELECT us.user_id,us.email,rl.role_type
        FROM users us
        JOIN users_role rl ON us.role_id=rl.role_id
        WHERE us.is_deleted=%s
    """,(0,))
    users=cursor.fetchall()
    return render_template('admin_notifications.html',notifications=notifications,courses=courses,users=users)


@admin.route('/send_notification',methods=['POST'])
@admin_required
def send_notification():
    cursor=mysql.connection.cursor()
    receiver_role=request.form['receiver_role']
    receiver_id=request.form.get('receiver_id') or None
    related_course_id=request.form.get('related_course_id') or None
    title=request.form['title']
    description=request.form['description']
    sender_id=session['user_id']
    sender_role='Admin'

    cursor.execute('''INSERT INTO notifications(sender_id,sender_role,receiver_id,receiver_role,title,description,related_course_id,status)
    VALUES(%s,%s,%s,%s,%s,%s,%s,%s)
    ''',(sender_id,sender_role,receiver_id,receiver_role,title,description,related_course_id,'Pending'))
    mysql.connection.commit()
    cursor.close()
    flash('Notification Send Successfully','success')
    return redirect(url_for('admin.admin_notifications'))    


@admin.route('/delete_notification',methods=['POST'])
@admin_required
def delete_notification():
    cursor=mysql.connection.cursor()

    notify_id=request.form.get('notif_id')
    current_status='Rejected'

    cursor.execute('UPDATE notifications SET is_deleted=%s,`status`=%s WHERE id=%s',(1,current_status,notify_id))
    mysql.connection.commit()
    cursor.close()
    flash('Nofitication Deleted Successfully','success')
    return redirect(url_for('admin.admin_notifications'))    

                              




    
    

        

