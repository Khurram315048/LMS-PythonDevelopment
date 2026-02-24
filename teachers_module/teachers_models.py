import MySQLdb.cursors
from utils.db import mysql 

class UserModel:
    @staticmethod
    def get_user_by_email(email):
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT user_id, password FROM users WHERE email = %s', (email,))
        user = cursor.fetchone()
        cursor.close()
        return user

    @staticmethod
    def create_user(email, password_hash):
        cursor = mysql.connection.cursor()
        cursor.execute('INSERT INTO users (email, password) VALUES (%s, %s)', (email, password_hash))
        mysql.connection.commit()
        user_id = cursor.lastrowid
        cursor.close()
        return user_id


class TeacherModel:
    @staticmethod
    def get_teacher_by_id(teacher_id):
        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM teachers WHERE teacher_id = %s', (teacher_id,))
        teacher = cursor.fetchone()
        cursor.close()
        return teacher        