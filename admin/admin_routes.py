from flask import Blueprint, render_template, request, redirect, url_for, session, flash, abort, current_app
from utils.auth import login_required
from werkzeug.security import check_password_hash ,generate_password_hash
from werkzeug.utils import secure_filename
import os
from datetime import datetime
import MySQLdb.cursors
from utils.db import mysql 

admin=Blueprint('admin', __name__, template_folder='admin_views')


@admin.route('/admin_login',methods=['GET','POST'])
def admin_login():
    cursor = mysql.connection.cursor()
    if request.method =='POST':
        email=request.form['email']
        password=request.form['password']
        remember = 'remember_me' in request.form

        cursor.execute('SELECT * FROM users WHERE email=%s',(email,))
        admin_details=cursor.fetchone()
        if admin_details and check_password_hash(admin_details['password'],password):
            cursor.execute('SELECT * FROM admins WHERE email=%s',(email,))
            admin_data=cursor.fetchone()
            session['user_id'] = admin_details['user_id']
            session['role'] = 'admin'
            session['admin_id'] = admin_data['admin_id']
            session.permanent = remember
            return redirect(url_for('admin.admin_dashboard'))
        else:
            return render_template('main_view.html')
    return render_template('admin_login.html')    
    

@admin.route('/admin_dashboard', methods=['GET', 'POST'])
@login_required
def admin_dashboard():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT COUNT(*) AS total_students FROM students')
    students=cursor.fetchone()['total_students']
    cursor.execute('SELECT COUNT(*) AS total_teachers FROM teachers')
    teachers=cursor.fetchone()['total_teachers']
    cursor.execute('SELECT COUNT(*) AS pending_fee FROM student_fees WHERE fee_status=%s',("due",))
    pending=cursor.fetchone()['pending_fee']
    cursor.execute('SELECT COUNT(*) AS total_courses FROM courses')
    courses_count=cursor.fetchone()['total_courses']
    cursor.execute('SELECT COUNT(*) AS total_fyp FROM fyp_groups')
    fyp_count=cursor.fetchone()['total_fyp']
    cursor.execute('SELECT COUNT(*) AS total_complaints FROM complaint_suggestion')
    complaints_count=cursor.fetchone()['total_complaints']
    return render_template(
        'admin_dashboard.html',
        students_count=students,
        teachers_count=teachers,complaints_count=complaints_count,
        pending_count=pending,courses_count=courses_count,fyp_count=fyp_count)


@admin.route('/admin_profile', methods=['GET', 'POST'])
@login_required
def admin_profile():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    admin_id=session.get('admin_id')
    
    cursor.execute('SELECT * FROM admins WHERE admin_id=%s', (admin_id,))
    admin_data=cursor.fetchone()
    if request.method=='POST':
        return redirect(url_for('admin.admin_edit'))
    
    return render_template('admin_profile.html', admin=admin_data)


@admin.route('/admin_edit', methods=['GET', 'POST'])
@login_required
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
@login_required
def system_settings():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM system_settings')
    settings=cursor.fetchall()
    return render_template('system_settings.html',settings=settings)    
    


@admin.route('/edit_settings', methods=['GET', 'POST'])
@login_required
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
@login_required
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
@login_required
def solve_complaint():
    cursor=mysql.connection.cursor()
    complt_sugst_id=request.form.get('complt_sugst_id') 
    cursor.execute('UPDATE complaint_suggestion SET is_status=%s WHERE complt_sugst_id=%s',("Solved",complt_sugst_id))
    mysql.connection.commit()
    flash('Complaint marked as solved.', 'success')
    return redirect(url_for('admin.complaints'))  
      

@admin.route('/system_controls',methods=['GET','POST'])
@login_required
def system_controls():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT * FROM semester WHERE is_deleted=%s',(0,))
    semesters=cursor.fetchall()
    return render_template('system_controls.html',semesters=semesters)


@admin.route('/add_semester',methods=['GET','POST'])
@login_required
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
@login_required
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
@login_required
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
@login_required
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
@login_required
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
@login_required
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
@login_required
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

        

