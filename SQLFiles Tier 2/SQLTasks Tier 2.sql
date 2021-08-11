/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

Code:
SELECT `name` 
FROM `Facilities` 
WHERE `membercost`> 0;

Answer: Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2, and Squash Court

/* Q2: How many facilities do not charge a fee to members? */

Code: 
SELECT `name` 
FROM `Facilities` 
WHERE `membercost` = 0;

Answer: Badminton Court, Table Tennis, Snooker Table, Pool Table


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Code: 
SELECT `facid`, `name`, `membercost`, `monthlymaintenance` 
FROM `Facilities` 
WHERE `membercost` > 0 AND `membercost` < .2 * `monthlymaintenance`;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

Code:
SELECT * 
FROM `Facilities` 
WHERE `facid` IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

Code:
SELECT name, `monthlymaintenance`, 
CASE WHEN `monthlymaintenance` > 100 THEN 'expensive' 
ELSE 'cheap' END AS costly 
FROM `Facilities`;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Code:
SELECT `firstname`,`surname`,`joindate` 
FROM `Members` 
WHERE joindate = (SELECT MAX(joindate) FROM Members);



/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Code:

SELECT DISTINCT CONCAT( `firstname` , ' ', `surname` ) AS Member, (
CASE WHEN `facid` =0
THEN 'Tennis Court 1'
ELSE 'Tennis Court 2'
END
) AS Court
FROM Members
LEFT JOIN Bookings 
ON Bookings.memid = Members.memid
WHERE facid IN ( 0, 1 )
ORDER BY Member;



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Code:

SELECT CONCAT( `firstname` , ' ', `surname` ) AS Member, name AS Facility, (
CASE WHEN Bookings.memid =0
THEN guestcost * slots
ELSE membercost * slots
END
) AS Cost
FROM Members
LEFT JOIN Bookings ON Bookings.memid = Members.memid
LEFT JOIN Facilities ON Facilities.facid = Bookings.facid
WHERE (
CASE WHEN Bookings.memid =0
THEN guestcost * slots
ELSE membercost * slots
END
) >30 AND Bookings.starttime LIKE '2012-09-14%'
ORDER BY Cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT CONCAT( `firstname` , ' ', `surname` ) AS Member, name AS Facility, (
CASE WHEN Sub.memid =0
THEN guestcost * slots
ELSE membercost * slots
END
) AS Cost
FROM Members
LEFT JOIN (Select memid, facid, starttime, slots 
           FROM Bookings 
          WHERE starttime LIKE '2012-09-14%') AS Sub 
ON Sub.memid = Members.memid
LEFT JOIN Facilities ON Facilities.facid = Sub.facid
WHERE (
CASE WHEN Sub.memid =0
THEN guestcost * slots
ELSE membercost * slots
END
) >30
ORDER BY Cost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

***Ran codes in file SQLite Code, then transcribed code here***

import sqlite3
con = sqlite3.connect('sqlite_db_pythonsqlite.db')
cur = con.cursor()

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

query = 'SELECT name AS facility, SUM(sub.Cost) AS revenue FROM  (Select Bookings.facid, (CASE WHEN memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS Cost FROM Bookings LEFT JOIN Facilities ON Facilities.facid = Bookings.facid) As sub LEFT JOIN Facilities ON Facilities.facid = sub.facid GROUP BY sub.facid HAVING SUM(sub.Cost) < 1000 ORDER BY SUM(sub.Cost)'
for row in cur.execute(query):
    print(row)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

query = "SELECT m1.surname, m1.firstname, (CASE WHEN m1.recommendedby < 1 THEN NULL ELSE m2.surname || ' ' || m2.firstname END) AS Recommended_By FROM (SELECT surname, firstname, `recommendedby` FROM `Members`) AS m1 LEFT JOIN Members AS m2 ON m1.recommendedby = m2.memid ORDER BY m1.surname, m1.firstname"
for row in cur.execute(query):
    print(row)

/* Q12: Find the facilities with their usage by member, but not guests */

query = "SELECT name AS Facility, memid, Count(*) AS Member_Usage FROM (SELECT facid, memid FROM Bookings WHERE memid > 0) AS sub LEFT JOIN Facilities ON sub.facid = Facilities.facid GROUP BY name, memid ORDER BY name"
for row in cur.execute(query):
    print(row)

/* Q13: Find the facilities usage by month, but not guests */

# Q13: Find the facilities usage by month, but not guests 

query = "SELECT name AS Facility, month, Count(*) AS Member_Usage FROM (SELECT facid, strftime('%m',starttime) as month FROM Bookings WHERE memid > 0) AS sub LEFT JOIN Facilities ON sub.facid = Facilities.facid GROUP BY name, month ORDER BY name"
for row in cur.execute(query):
    print(row)