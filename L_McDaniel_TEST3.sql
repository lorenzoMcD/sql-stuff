-- Lorenzo McDaniel
CREATE TABLE SCHEDULE AS SELECT * FROM MAG.SCHEDULE;
CREATE TABLE PART AS SELECT * FROM MAG.PART;
CREATE TABLE WORKER AS SELECT * FROM MAG.WORKER;
CREATE TABLE JOB AS SELECT * FROM MAG.JOB;
CREATE TABLE EQUIPMENT AS SELECT * FROM MAG.EQUIPMENT;



-- 1 WORKS COMPLETE
SELECT (WORKER.WORK_FNAME || ' ' || WORK_LNAME) AS WORKER, PART.PART_DESCRIPT, TO_CHAR (Round(AVG((WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) / JOB_QTY_PRODUCED),2),'$0.99') AS " Avg Labor Cost per Unit", Count(JOB_QTY_PRODUCED) AS " Times Produced"
FROM   WORKER JOIN JOB ON WORKER.WORK_NUM = JOB.WORK_NUM
        JOIN PART ON JOB.PART_NUM = PART.PART_NUM
HAVING   Count(JOB_QTY_PRODUCED) > 2
GROUP BY WORKER.WORK_FNAME, WORKER.WORK_LNAME , PART.PART_DESCRIPT
ORDER BY AVG((WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) / JOB_QTY_PRODUCED);


-- 2    WORKS COMPLETE
SELECT PART.PART_NUM, PART_DESCRIPT, PART_QOH, SCHEDULE.SCH_PLAN_QTY
FROM  PART LEFT JOIN SCHEDULE ON PART.PART_NUM = SCHEDULE.PART_NUM
WHERE      (SCH_PLAN_QTY < 5000   OR SCH_PLAN_QTY IS NULL) AND  PART_QOH > 50 AND
           (PART_DESCRIPT LIKE  '%bar%'OR Upper(PART_DESCRIPT) LIKE '%BAR%' OR PART_DESCRIPT LIKE '%bracket%' OR Upper(PART_DESCRIPT) LIKE '%BRACKET%'  )
ORDER BY PART_QOH , SCH_PLAN_QTY;



-- 3  WORKS COMPLETE
SELECT WORKER.WORK_LNAME, EQUIPMENT.EQUIP_NUM, EQUIP_TYPE, To_Char(JOB.JOB_STARTTIME, 'YYYY-MM-DD'), ( WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) + (EQUIPMENT.EQUIP_STARTUP_COST + ( EQUIP_HOURLY_RUN_COST * JOB.JOB_HOURS_WORKED) ), JOB.JOB_QTY_PRODUCED
FROM WORKER JOIN JOB ON WORKER.WORK_NUM = JOB.WORK_NUM
     JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
WHERE   ( WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) + (EQUIPMENT.EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * JOB.JOB_HOURS_WORKED)) > 200 AND JOB_QTY_PRODUCED < 300
ORDER BY   ( WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) + (EQUIPMENT.EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * JOB.JOB_HOURS_WORKED)) DESC , JOB_QTY_PRODUCED;


-- 4 WORKS COMPLETE
 SELECT WORKER.WORK_NUM, WORK_LNAME, WORK_FNAME,JOB.EQUIP_NUM , Count(EQUIPMENT.EQUIP_HOURLY_RUN_COST) AS "Times Worker Used", Round(AVG( JOB.JOB_QTY_PRODUCED / JOB_HOURS_WORKED),3) AS "Worker on Equip Avg", EQUIP_AVG_ALL_WORKERS AS "Equip Avg Productivity"
FROM (SELECT EQUIPMENT.EQUIP_NUM , Round(AVG( JOB.JOB_QTY_PRODUCED / JOB_HOURS_WORKED),3) AS EQUIP_AVG_ALL_WORKERS
      FROM JOB JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
      GROUP BY EQUIPMENT.EQUIP_NUM ) EQUIPAVG JOIN EQUIPMENT ON EQUIPMENT.EQUIP_NUM =  EQUIPAVG.EQUIP_NUM JOIN JOB ON EQUIPAVG.EQUIP_NUM = JOB.EQUIP_NUM JOIN WORKER ON JOB.WORK_NUM = WORKER.WORK_NUM
GROUP BY WORKER.WORK_NUM, WORK_LNAME, WORK_FNAME, JOB.EQUIP_NUM, EQUIP_AVG_ALL_WORKERS
HAVING Count(EQUIPMENT.EQUIP_HOURLY_RUN_COST) > 2
ORDER BY WORKER.WORK_NUM ;


-- 5  WORKS COMPLETE
SELECT '(' ||   PART.PART_NUM ||  ')' || ' ' || PART_DESCRIPT AS PART, Count(JOB_NUM) AS " Number of Jobs", Count(DISTINCT(WORK_NUM)) AS " Different Workers", Count(DISTINCT(EQUIPMENT.EQUIP_NUM)) AS " Different Equipment"
FROM PART LEFT JOIN JOB ON PART.PART_NUM = JOB.PART_NUM LEFT JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
WHERE PART_QOH < 100
GROUP BY PART.PART_NUM, PART_DESCRIPT
ORDER BY Count(JOB_QTY_PRODUCED) DESC;



-- 6  WORKS COMPLETE
SELECT SCHEDULE.PART_NUM , Round(Avg(SCH_NEED_DATE - SCH_CREATE_DATE),1) AS " Average Lead Time"
FROM (  SELECT PART_NUM, Avg(SCH_NEED_DATE - SCH_CREATE_DATE)
       FROM SCHEDULE
       GROUP BY PART_NUM)FAVG JOIN SCHEDULE ON FAVG.PART_NUM = SCHEDULE.PART_NUM
WHERE SCHEDULE.SCH_ACTUAL_QTY IS NOT NULL
GROUP BY SCHEDULE.PART_NUM ;


-- 7   WORKS COMPLETE
SELECT WORK.WORK_NUM, WORK.WORK_LNAME, WORK.WORK_FNAME
FROM  ( SELECT DISTINCT(WORKER.WORK_NUM), WORK_FNAME ,WORK_LNAME, Count(WORK_TITLE)
        FROM WORKER LEFT JOIN JOB ON WORKER.WORK_NUM = JOB.WORK_NUM LEFT JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
        HAVING COUNT(WORK_TITLE) = 1
        GROUP BY WORKER.WORK_NUM, WORK_FNAME,WORK_LNAME, WORK_TITLE) WORK JOIN WORKER ON WORK.WORK_NUM = WORKER.WORK_NUM  LEFT JOIN JOB ON WORKER.WORK_NUM= JOB.WORK_NUM LEFT JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
WHERE WORK_TITLE LIKE ('%Machinist%') AND (EQUIPMENT.EQUIP_TYPE NOT LIKE ('%WELDER%') OR EQUIPMENT.EQUIP_TYPE IS NULL)
ORDER BY WORK.WORK_LNAME, WORK.WORK_FNAME;



-- 8 WORKS COMPLETE
SELECT WORKER.WORK_NUM, WORK_FNAME || ' ' || WORK_LNAME AS WORKER, Count(JOB.JOB_NUM) AS "Number of Jobs"
FROM WORKER LEFT JOIN JOB ON WORKER.WORK_NUM = JOB.WORK_NUM
WHERE WORKER.WORK_WAGE > 30
GROUP BY WORKER.WORK_NUM ,  WORK_FNAME || ' ' || WORK_LNAME
ORDER BY  Count(JOB.JOB_NUM) DESC , WORK_FNAME || ' ' || WORK_LNAME ;


-- 9 WORKS COMPLETE

SELECT DISTINCT(JOB.JOB_NUM), PART.PART_NUM , PART.PART_DESCRIPT,  JOB.JOB_STARTTIME, WORKER.WORK_LNAME, WORK_TITLE AS "Title", Round((WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED),1) AS "Labor Cost", JOB.JOB_QTY_PRODUCED AS "Units Produced"
FROM  (SELECT EQUIPMENT.EQUIP_NUM, EQUIP_TYPE , JOB.JOB_QTY_PRODUCED , JOB.JOB_NUM
       FROM JOB JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM WHERE EQUIP_TYPE = 'INJECTOR')
INJECT_CHECK JOIN JOB ON INJECT_CHECK.EQUIP_NUM  = JOB.EQUIP_NUM  JOIN EQUIPMENT ON EQUIPMENT.EQUIP_NUM = JOB.EQUIP_NUM  JOIN PART ON PART.PART_NUM = JOB.PART_NUM  JOIN WORKER ON JOB.WORK_NUM = WORKER.WORK_NUM
WHERE (WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED) > ( SELECT MAX(WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED)
                                                    FROM WORKER JOIN JOB ON WORKER.WORK_NUM = JOB.WORK_NUM JOIN EQUIPMENT ON JOB.EQUIP_NUM = EQUIPMENT.EQUIP_NUM
                                                    WHERE EQUIPMENT.EQUIP_TYPE LIKE ('%ROBOTIC%'))
ORDER BY Round((WORKER.WORK_WAGE * JOB.JOB_HOURS_WORKED),1) DESC, JOB.JOB_QTY_PRODUCED ;


-- 10   WORKS COMPLETE
SELECT DISTINCT(EQUIPMENT.EQUIP_NUM) , EQUIP_TYPE, To_Char(( EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * 1)),'$0.99') AS "1 HOUR RUN"  ,   To_Char(( EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * 4)),'$99.99') AS "4 HOUR RUN", To_Char(( EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * 8)),'$99.99') AS "8 HOUR RUN"
FROM EQUIPMENT LEFT JOIN JOB ON EQUIPMENT.EQUIP_NUM = JOB.EQUIP_NUM
WHERE EQUIPMENT.EQUIP_TYPE = 'REAMER' OR EQUIP_TYPE = 'ARC WELDER' OR EQUIP_TYPE = 'MANUAL PRESS'
ORDER BY EQUIPMENT.EQUIP_TYPE, To_Char(( EQUIP_STARTUP_COST + (EQUIP_HOURLY_RUN_COST * 1)),'$0.99');


