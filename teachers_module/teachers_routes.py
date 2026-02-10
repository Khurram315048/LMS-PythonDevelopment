from flask import Blueprint, render_template, request, redirect, url_for, session, flash
import MySQLdb.cursors
from utils.auth import login_required
from utils.db import mysql
from datetime import datetime
from datetime import date
import datetime
from werkzeug.security import check_password_hash, generate_password_hash

teacher = Blueprint('teacher', __name__, template_folder='teachers_views')



@teacher.route('/teacher_profile', methods=['GET', 'POST'])
@login_required
def teacher_profile():
    if session.get('role') != 'teacher':
        return redirect(url_for('main_view'))
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM teachers WHERE teacher_id=%s', (session['teacher_id'],))
    teacher_details=cursor.fetchone()
    return render_template('teacher_profile.html',teacher_details=teacher_details)



@teacher.route('/teacher_login', methods=['GET', 'POST'])
def teacher_login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM teachers WHERE email=%s', (email,))
        user = cursor.fetchone()
        cursor.execute('SELECT * FROM users WHERE email=%s',(email,))
        logged_user=cursor.fetchone()
        if user and check_password_hash(logged_user['password'],password):
            session['user_id'] = user['user_id']
            session['role'] = 'teacher'
            session['teacher_id'] = user['teacher_id']
            return redirect(url_for('teacher.teacher_dashboard'))
        else:
            return redirect(url_for('teacher.teacher_login'))
    return render_template('teacher_login.html')



@teacher.route('/teacher_dashboard')
@login_required
def teacher_dashboard():
    if session.get('role') != 'teacher':
        return redirect(url_for('main_view'))

    teacher_id = session.get('teacher_id')
    today_name = datetime.datetime.now().strftime('%A')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = '''
    SELECT 
        tc.teacher_course_id,
        p.program_coordinator AS coordinator_name,
        p.program_name AS class_name,
        c.course_id,
        c.course_name,
        s.semester,
        s.section_id,
        s.section_name AS section,
        cs.day_of_week,
        TIME_FORMAT(cs.start_time, '%%h:%%i %%p') as start,
        TIME_FORMAT(cs.end_time, '%%h:%%i %%p') as end
    FROM teacher_course tc
    JOIN courses c ON tc.course_id = c.course_id
    JOIN programs p ON c.program_id = p.program_id
    JOIN sections s ON c.course_id = s.course_id
    JOIN course_schedule cs ON s.section_id = cs.section_id
    WHERE tc.teacher_id = %s
    ORDER BY FIELD(cs.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), cs.start_time;
    '''
    
    cursor.execute(query, (teacher_id,))
    full_schedule = cursor.fetchall()

    today_schedule = [row for row in full_schedule if row['day_of_week'] == today_name]

    cursor.close()
    
    return render_template('teacher_dashboard.html', 
                           full_schedule=full_schedule, 
                           today_schedule=today_schedule,
                           today_name=today_name)


@teacher.route("/class_attendance",methods=['GET','POST'])
@login_required
def class_attendance():
    cursor=mysql.connection.cursor()
    teacher_id = session.get('teacher_id')
    today_name = datetime.datetime.now().strftime('%A')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = '''
    SELECT 
        tc.teacher_course_id,
        p.program_coordinator AS coordinator_name,
        p.program_name AS class_name,
        c.course_id,
        s.semester,
        s.section_id,
        c.course_name,
        s.section_name AS section,
        cs.day_of_week,
        TIME_FORMAT(cs.start_time, '%%h:%%i %%p') as start,
        TIME_FORMAT(cs.end_time, '%%h:%%i %%p') as end
    FROM teacher_course tc
    JOIN courses c ON tc.course_id = c.course_id
    JOIN programs p ON c.program_id = p.program_id
    JOIN sections s ON c.course_id = s.course_id
    JOIN course_schedule cs ON s.section_id = cs.section_id
    WHERE tc.teacher_id = %s
    ORDER BY FIELD(cs.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), cs.start_time;
    '''
    
    cursor.execute(query, (teacher_id,))
    full_schedule = cursor.fetchall()

    today_schedule = [row for row in full_schedule if row['day_of_week'] == today_name]

    cursor.close()
    
    return render_template('class_attendance.html',full_schedule=full_schedule, 
                           today_schedule=today_schedule,
                           today_name=today_name)                           



@teacher.route("/class_structure/<int:section_id>", methods=['GET', 'POST'])
@login_required
def class_structure(section_id):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = '''
    SELECT 
        c.course_id AS class_id, p.program_coordinator,p.program_name , s.semester, 
        c.course_name  , s.section_name,s.section_id,
        (SELECT COUNT(*) FROM student_section WHERE section_id = s.section_id) as total_enroll
    FROM sections s
    JOIN courses c on s.course_id=c.course_id
    JOIN programs p ON c.program_id = p.program_id
    WHERE s.section_id = %s
    '''
    cursor.execute(query, (section_id,))
    class_info = cursor.fetchall()
    cursor.close()
    
    return render_template('class_structure.html', class_info=class_info)


@teacher.route("/toggle_upload/<int:section_id>/<string:upload_type>", methods=['POST'])
@login_required
def toggle_upload(section_id, upload_type):
    cursor = mysql.connection.cursor()
    if upload_type == 'assignment':
        cursor.execute("UPDATE sections SET assignments_enabled = 1 - assignments_enabled WHERE section_id = %s", (section_id,))
    elif upload_type == 'quiz':
        cursor.execute("UPDATE sections SET quizzes_enabled = 1 - quizzes_enabled WHERE section_id = %s", (section_id,))
    
    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('teacher.class_structure', section_id=section_id))



@teacher.route("/marked_attendance/<int:section_id>", methods=['GET', 'POST'])
@login_required
def marked_attendance(section_id):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    
    cursor.execute('''
        SELECT c.course_name, c.course_id, cs.course_schedule_id 
        FROM sections s
        JOIN courses c ON s.course_id = c.course_id
        JOIN course_schedule cs ON s.section_id = cs.section_id
        WHERE s.section_id = %s LIMIT 1
    ''', (section_id,))
    class_info = cursor.fetchone()

    if not class_info:
        return "Error: Schedule not found for this section."

   
    attendance_date = request.form.get('attendance_date') or request.args.get('date') or str(date.today())

    cursor.execute('''
        SELECT COUNT(*) as count FROM attendance 
        WHERE course_schedule_id = %s AND attendance_date = %s
    ''', (class_info['course_schedule_id'], attendance_date))
    already_marked = cursor.fetchone()['count'] > 0

    if request.method == 'POST':
        
        if already_marked:
            return "Error: Attendance already marked for this date."

        attendance_data = []
        cursor.execute('''
            SELECT sc.student_course_id, sc.student_id 
            FROM student_course sc
            JOIN student_section ss ON sc.student_id = ss.student_id
            WHERE ss.section_id = %s AND sc.course_id = %s
        ''', (section_id, class_info['course_id']))
        students_list = cursor.fetchall()

        for student in students_list:
            status = request.form.get(f"status_{student['student_course_id']}", "Absent")
            attendance_data.append((
                student['student_course_id'], 
                class_info['course_schedule_id'], 
                attendance_date, 
                status, 
                student['student_id']
            ))

        insert_query = '''
            INSERT INTO attendance (student_course_id, course_schedule_id, attendance_date, attendance_status, student_id)
            VALUES (%s, %s, %s, %s, %s)
        '''
        cursor.executemany(insert_query, attendance_data)
        mysql.connection.commit()
        return redirect(url_for('teacher.class_attendance'))

    
    cursor.execute('''
    SELECT 
        ss.student_id, 
        CONCAT(s.first_name, ' ', s.last_name) AS student_name, 
        sc.student_course_id
    FROM student_section ss
    JOIN student_course sc ON ss.student_id = sc.student_id
    JOIN students s ON ss.student_id = s.student_id  -- Changed join to 'students' table
    WHERE ss.section_id = %s AND sc.course_id = %s
    ''', (section_id, class_info['course_id']))
    students = cursor.fetchall()

    return render_template('marked_attendance.html', 
                           course_name=class_info['course_name'],
                           students=students,
                           attendance_date=attendance_date,
                           already_marked=already_marked, 
                           section_id=section_id)


@teacher.route('/fyp_management')
@login_required
def fyp_management():
    teacher_id = session.get('teacher_id')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = """
        SELECT f.*, 
               s.first_name, s.last_name, s.student_id as reg_num,
               s.contact, s.email,
               p.program_name, sec.semester
        FROM fyp_groups f
        JOIN students s ON f.student_id = s.student_id
        LEFT JOIN programs p ON s.program_id = p.program_id
        LEFT JOIN student_section ss ON s.student_id = ss.student_id
        LEFT JOIN sections sec ON ss.section_id = sec.section_id
        WHERE f.teacher_id = %s
    """
    cursor.execute(query, (teacher_id,))
    fyp_data = cursor.fetchall()
    for group in fyp_data:
        cursor.execute("""
            SELECT * FROM fyp_messages 
            WHERE fyp_id = %s 
            ORDER BY created_at ASC
        """, (group['fyp_id'],))
        messages = cursor.fetchall()
        group['messages'] = messages
        group['has_unread'] = False
        if messages and messages[-1]['sender_role'] == 'student':
            group['has_unread'] = True

    total = len(fyp_data)
    completed = len([g for g in fyp_data if g['status'] == 'Approved'])
    pending = len([g for g in fyp_data if g['status'] == 'Pending Approval'])
    
    cursor.close()
    return render_template('fyp_management.html', fyp_data=fyp_data, total=total, completed=completed, pending=pending)

@teacher.route('/approve_fyp/<int:fyp_id>/<string:status>')
@login_required
def approve_fyp(fyp_id, status):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE fyp_groups SET status=%s WHERE fyp_id=%s", (status, fyp_id))
    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('teacher.fyp_management'))                         



@teacher.route('/send_message/<int:fyp_id>', methods=['POST'])
@login_required
def send_message(fyp_id):
    if session.get('role') != 'teacher':
        return redirect(url_for('main_view'))

    message_text = request.form.get('message')
    teacher_id = session.get('teacher_id')
    
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT student_id FROM fyp_groups WHERE fyp_id=%s", (fyp_id,))
    result = cursor.fetchone() 
    if result:
        student_id = result['student_id']
        cursor.execute("""
            INSERT INTO fyp_messages (fyp_id, teacher_id, student_id, sender_role, message)
            VALUES (%s, %s, %s, 'teacher', %s)
        """, (fyp_id, teacher_id, student_id, message_text))
        
        mysql.connection.commit()
    
    cursor.close()
    return redirect(url_for('teacher.fyp_management'))


@teacher.route("/mark_submission/<int:submission_id>", methods=['POST'])
@login_required
def mark_submission(submission_id):
    total_marks=request.form.get('total_marks')
    obtained_marks = request.form.get('marks')
    section_id = request.form.get('section_id')
    sub_type = request.form.get('sub_type')
    
    cursor = mysql.connection.cursor()
    query = "UPDATE student_submissions SET marks = %s , total_marks=%s  WHERE submission_id = %s"
    cursor.execute(query, (obtained_marks,total_marks, submission_id))
    mysql.connection.commit()
    cursor.close()
    
    print("Marks updated successfully!", "success")
    return redirect(url_for('teacher.view_submissions', section_id=section_id, sub_type=sub_type))



@teacher.route("/view_submissions/<int:section_id>/<string:sub_type>")
@login_required
def view_submissions(section_id, sub_type):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    query = """
        SELECT sub.submission_id, sub.student_id, sub.file_path, sub.upload_date, 
               sub.marks, sub.total_marks, 
               s.first_name, s.last_name 
        FROM student_submissions sub
        JOIN students s ON sub.student_id = s.student_id
        WHERE sub.section_id = %s 
        AND LOWER(sub.submission_type) = LOWER(%s)
    """
    cursor.execute(query, (section_id, sub_type))
    submissions = cursor.fetchall()
    cursor.execute('''
        SELECT c.course_name, s.section_name 
        FROM sections s 
        JOIN courses c ON s.course_id = c.course_id 
        WHERE s.section_id = %s
    ''', (section_id,))
    info = cursor.fetchone()
    
    course_name = info['course_name'] if info else "Unknown Course"
    section_name = info['section_name'] if info else ""

    cursor.close()
    return render_template('view_submissions.html', 
                           submissions=submissions, 
                           sub_type=sub_type, 
                           course_name=f"{course_name} ({section_name})", 
                           section_id=section_id)




@teacher.route("/generate_result/<int:section_id>", methods=['GET', 'POST'])
@login_required
def generate_result(section_id):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('''
        SELECT s.section_id, s.section_name, s.semester, c.course_name, c.course_id 
        FROM sections s 
        JOIN courses c ON s.course_id = c.course_id 
        WHERE s.section_id = %s
    ''', (section_id,))
    class_details = cursor.fetchone()

    if not class_details:
        return redirect(url_for('teacher.teacher_dashboard'))

    if request.method == 'POST':
        cursor.execute('SELECT student_id FROM student_section WHERE section_id = %s', (section_id,))
        students_in_class = cursor.fetchall()

        for stud in students_in_class:
            sid = stud['student_id']
            
            if request.form.get(f'sessional_{sid}'):
                sessional = int(request.form.get(f'sessional_{sid}', 0))
                mids = int(request.form.get(f'mids_{sid}', 0))
                final = int(request.form.get(f'final_{sid}', 0))
                total = sessional + mids + final
                
                
                if total >= 95: grade, gpa = 'A+', 4.0
                elif total >= 90: grade, gpa = 'A-', 3.8
                elif total >= 85: grade, gpa = 'A', 3.6
                elif total >= 80: grade, gpa = 'B+', 3.4
                elif total >= 75: grade, gpa = 'B-', 3.2
                elif total >= 70: grade, gpa = 'B', 3.0
                elif total >= 65: grade, gpa = 'C+', 2.8
                elif total >= 60: grade, gpa = 'C-', 2.6
                elif total >= 55: grade, gpa = 'C', 2.4
                elif total >= 50: grade, gpa = 'D', 2.3
                else: grade, gpa = 'F', 0.0

                current_status = 'Pass' if total >= 50 else 'Fail'
                
                cursor.execute('SELECT student_course_id FROM student_course WHERE student_id = %s AND course_id = %s', 
                               (sid, class_details['course_id']))
                sc_record = cursor.fetchone()
                
                if sc_record:
                    
                    cursor.execute('SELECT student_result_id FROM student_results WHERE student_id = %s AND student_semester = %s', 
                                   (sid, class_details['semester']))
                    res_parent = cursor.fetchone()
                    
                    if res_parent:
                        res_id = res_parent['student_result_id']
                    else:
                        cursor.execute('INSERT INTO student_results (student_id, student_semester, result_status, overall_gpa) VALUES (%s, %s, %s,%s)', 
                                       (sid, class_details['semester'], current_status,gpa))
                        res_id = cursor.lastrowid

                    cursor.execute('''
                        INSERT INTO student_result_marks 
                        (student_course_id, student_result_id, total_marks, student_grade, status, 
                         student_semester, sessional_marks, mid_marks, final_marks, subject_gpa)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON DUPLICATE KEY UPDATE 
                        total_marks=%s, student_grade=%s, status=%s, sessional_marks=%s, mid_marks=%s, final_marks=%s, subject_gpa=%s
                    ''', (sc_record['student_course_id'], res_id, total, grade, current_status, class_details['semester'], sessional, mids, final, gpa,
                          total, grade, current_status, sessional, mids, final, gpa))

        mysql.connection.commit()
        flash("Results have been updated successfully!", "success")
        return redirect(url_for('teacher.teacher_dashboard'))

   
    cursor.execute('''
        SELECT 
            s.student_id, s.first_name, s.last_name,
            srm.marks_id AS has_result,
            srm.student_grade,
            srm.total_marks
        FROM students s
        JOIN student_section ss ON s.student_id = ss.student_id
        JOIN student_course sc ON s.student_id = sc.student_id AND sc.course_id = %s
        LEFT JOIN student_result_marks srm ON (sc.student_course_id = srm.student_course_id)
        WHERE ss.section_id = %s
    ''', (class_details['course_id'], section_id))
    
    students = cursor.fetchall()
    cursor.close()

    return render_template('generate_result.html', students=students, info=class_details)