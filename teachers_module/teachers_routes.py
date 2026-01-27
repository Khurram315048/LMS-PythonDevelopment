from flask import Blueprint, render_template, request, redirect, url_for, session
import MySQLdb.cursors
from utils.auth import login_required
from utils.db import mysql
from datetime import datetime
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

    if request.method == 'POST':
        attendance_date = request.form.get('attendance_date')
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
        
        return redirect(url_for('teacher.teacher_dashboard'))

    cursor.execute('''
        SELECT sc.student_course_id, s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS student_name
        FROM student_course sc
        JOIN students s ON sc.student_id = s.student_id
        JOIN student_section ss ON s.student_id = ss.student_id
        WHERE ss.section_id = %s AND sc.course_id = %s
    ''', (section_id, class_info['course_id']))
    students = cursor.fetchall()
    
    cursor.execute('SELECT COUNT(DISTINCT attendance_date) + 1 as next_lec FROM attendance WHERE course_schedule_id = %s', (class_info['course_schedule_id'],))
    lec_count = cursor.fetchone()

    cursor.close()
    return render_template('marked_attendance.html', 
                           students=students, 
                           course_name=class_info['course_name'],
                           lecture_no=lec_count['next_lec'],
                           attendance_date=datetime.datetime.now().strftime('%Y-%m-%d'))



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