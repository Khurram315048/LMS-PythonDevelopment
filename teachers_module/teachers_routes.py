from flask import Blueprint, render_template, request, redirect, url_for, session
#import MySQLdb.cursors
from utils.auth import login_required
from utils.db import mysql
from datetime import datetime
from werkzeug.security import check_password_hash, generate_password_hash

teacher = Blueprint('teacher', __name__, template_folder='teachers_views')

@teacher.route('/teacher_login', methods=['GET', 'POST'])
def teacher_login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM teachers WHERE email=%s', (email,))
        user = cursor.fetchone()
        if user :#and check_password_hash(user['password'], password):
            cursor.execute('SELECT * FROM teachers WHERE user_id=%s', (user['user_id'],))
            teacher = cursor.fetchone()
            if teacher:
                session['user_id'] = user['user_id']
                session['user_type'] = 'teacher'
                session['teacher_id'] = teacher['teacher_id']
                return redirect(url_for('teacher.teacher_dashboard', teacher=teacher))
        else:
            return redirect(url_for('teacher.teacher_login'))
    return render_template('teacher_login.html')

@teacher.route('/teacher_profile', methods=['GET', 'POST'])
@login_required
def teacher_profile():
    if session.get('user_type') != 'teacher':
        return redirect(url_for('main_view'))
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM teachers WHERE teacher_id=%s', (session['teacher_id'],))
    teacher_details=cursor.fetchone()
    return render_template('teacher_profile.html',teacher_details=teacher_details)

@teacher.route('/teacher_dashboard', methods=['GET', 'POST'])
@login_required
def teacher_dashboard():
    if session.get('user_type') != 'teacher':
        return redirect(url_for('main_view'))

    cursor=mysql.connection.cursor()
    user_id=session['user_id']

    cursor.execute('SELECT teacher_id FROM teachers WHERE user_id=%s', (user_id,))
    teacher_row=cursor.fetchone()
    if not teacher_row:
        cursor.close()
        return render_template('teacher_dashboard.html', message="No teacher profile found.")

    teacher_id=teacher_row['teacher_id']
    cursor.execute('''
        SELECT DISTINCT
            cs.course_schedule_id,
            c.course_name AS course_name,
            p.program_name AS class,
            s.semester AS semester,
            s.section_name AS section,
            cs.location AS location,
            CONCAT(cs.day_of_week, ' ', cs.start_time, ' - ', cs.end_time) AS time
        FROM course_schedule cs
        JOIN courses c ON cs.course_id = c.course_id
        JOIN programs p ON c.program_id = p.program_id
        JOIN sections s ON cs.section_id = s.section_id
        JOIN teacher_course tc ON c.course_id = tc.course_id
        WHERE tc.teacher_id = %s
        ORDER BY FIELD(cs.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), cs.start_time
    ''', (teacher_id,))
    schedule=cursor.fetchall()

    cursor.close()

    if not schedule or not isinstance(schedule,list):
        return render_template('teacher_dashboard.html', message="No schedule found.",schedule=[])

    return render_template('teacher_dashboard.html', schedule=schedule)

@teacher.route('/attendance/<int:schedule_id>', methods=['GET', 'POST'])
@login_required
def mark_attendance(schedule_id):
    if session.get('user_type') != 'teacher':
        return redirect(url_for('main_view'))

    cursor = mysql.connection.cursor()
    user_id = session['user_id']

    cursor.execute('SELECT teacher_id FROM teachers WHERE user_id=%s', (user_id,))
    teacher_row = cursor.fetchone()
    if not teacher_row:
        cursor.close()
        return render_template('attendance.html', message="No teacher profile found.")

    teacher_id = teacher_row['teacher_id']
    cursor.execute('''
        SELECT cs.course_id, c.course_name
        FROM course_schedule cs
        JOIN courses c ON cs.course_id = c.course_id
        JOIN teacher_course tc ON c.course_id = tc.course_id
        WHERE cs.course_schedule_id = %s AND tc.teacher_id = %s
    ''', (schedule_id, teacher_id))
    schedule_row = cursor.fetchone()
    if not schedule_row:
        cursor.close()
        return render_template('attendance.html', message="Invalid schedule or not assigned to you.")

    cursor.execute('''
        SELECT 
            s.student_id,
            CONCAT(s.first_name, ' ', s.last_name) AS student_name,
            sc.student_course_id
        FROM students s
        JOIN student_course sc ON s.student_id = sc.student_id
        JOIN student_section ss ON s.student_id = ss.student_id
        JOIN course_schedule cs ON sc.course_id = cs.course_id AND ss.section_id = cs.section_id
        WHERE cs.course_schedule_id = %s
        ORDER BY s.student_id
    ''', (schedule_id,))
    students = cursor.fetchall()

    if not students:
        cursor.close()
        return render_template('attendance.html', message="No students enrolled in this course section.")

    if request.method == 'POST':
        attendance_date = request.form.get('attendance_date')
        if not attendance_date:
            cursor.close()
            return render_template('attendance.html', students=students, course_name=schedule_row['course_name'], schedule_id=schedule_id, message="Please enter a valid date.")

        cursor.execute('''
            SELECT COUNT(*) AS lecture_count
            FROM attendance
            WHERE course_schedule_id = %s AND attendance_date < %s
        ''', (schedule_id, attendance_date))
        lecture_count = cursor.fetchone()['lecture_count']
        lecture_no = lecture_count + 1

        for student in students:
            status = request.form.get(f'status_{student["student_course_id"]}', 'Absent')
            cursor.execute('''
                INSERT INTO attendance (student_course_id, course_schedule_id, attendance_date, attendance_status,student_id)
                VALUES (%s, %s, %s, %s,%s)
            ''', (student['student_course_id'], schedule_id, attendance_date, status, student['student_id']))
        mysql.connection.commit()
        cursor.close()
        return redirect(url_for('teacher.teacher_dashboard'))

    attendance_date = datetime.today().strftime('%Y-%m-%d')
    cursor.execute('''
        SELECT COUNT(*) AS lecture_count
        FROM attendance
        WHERE course_schedule_id = %s AND attendance_date < %s
    ''', (schedule_id, attendance_date))
    lecture_count = cursor.fetchone()['lecture_count']
    lecture_no = lecture_count + 1

    cursor.close()
    return render_template('attendance.html', students=students, course_name=schedule_row['course_name'], schedule_id=schedule_id, lecture_no=lecture_no, attendance_date=attendance_date)

@teacher.route('/complaint_suggestions', methods=['GET', 'POST'])
@login_required
def complaint_suggestions():
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        user_id = session['user_id']
        # Save to database (you will add this)
        return redirect(url_for('teacher.teacher_dashboard'))
    
    return render_template('complaint_suggestions.html')
