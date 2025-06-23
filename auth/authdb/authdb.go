package authdb

import (
	"crypto/md5"
	"database/sql"
	"encoding/hex"
	"fmt"
)

type User struct {
	ID       int    `json:"user_id"`
	Name     string `json:"user_name"`
	Password string `json:"user_password"`
}

func Connect(dbUser, dbPassword, dbHost, dbPort string) (*sql.DB, error) {
	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%s)/", dbUser, dbPassword, dbHost, dbPort))
	if err != nil {
		return nil, err
	}
	return db, nil
}

func CreateDB(db *sql.DB, dbName string) {
	cmd, err := db.Query(fmt.Sprintf("CREATE DATABASE IF NOT EXISTS %s", dbName))
	if err != nil {
		fmt.Println(err.Error())
	}
	defer cmd.Close()
}
func CreateTables(db *sql.DB, dbName string) {
	cmd, err := db.Query(fmt.Sprintf("CREATE TABLE IF NOT EXISTS %s.users (user_id int AUTO_INCREMENT,  user_name char(50) NOT NULL, user_password char(128), PRIMARY KEY(user_id));", dbName))
	if err != nil {
		fmt.Println(err.Error())
	}
	defer cmd.Close()
}
func InsertUser(db *sql.DB, user User, dbName string) error {
	password := md5.Sum([]byte(user.Password))
	cmd, err := db.Query(fmt.Sprintf("INSERT INTO %s.users (user_name,user_password) VALUES ('%s','%s');", dbName, user.Name, hex.EncodeToString(password[:])))
	if err != nil {
		return err
	}
	defer cmd.Close()
	return nil
}
func GetUserByName(user_name string, db *sql.DB, dbName string) (User, error) {
	var user User
	results, err := db.Query(fmt.Sprintf("SELECT * FROM %s.users where user_name = '%s'", dbName, user_name))
	if err != nil {
		return user, err
	}
	defer results.Close()
	for results.Next() {
		err = results.Scan(&user.ID, &user.Name, &user.Password)
		if err != nil {
			return user, err
		}
	}
	return user, nil
}
func CreateUser(db *sql.DB, u User, dbName string) (bool, error) {
	user, err := GetUserByName(u.Name, db, dbName)
	if err != nil {
		return false, err
	}
	if user != (User{}) {
		return false, nil
	} else {
		err := InsertUser(db, u, dbName)
		if err != nil {
			return false, err
		} else {
			return true, nil
		}
	}
}
