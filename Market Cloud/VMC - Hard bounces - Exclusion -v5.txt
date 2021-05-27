SELECT w.ID_EMAIL 
	, w.EMAIL_ADDR  
	, w.BOUNCECATEGORY  
	, w.JOBID 
	, w.EMAILNAME  
	, w.DATE_BOUNCED
	, w.DATE_ADDED
FROM( 
	 SELECT s.SubscriberKey             AS ID_EMAIL 
		   , LOWER(s.EmailAddress)      AS EMAIL_ADDR  
		   , b.BOUNCECATEGORY  
		   , jb.JOBID 
		   , jb.EMAILNAME  
		   , CAST(b.EVENTDATE AS DATE)  AS DATE_BOUNCED
		   , CONVERT(DATE, GETDATE())   AS DATE_ADDED
		   , ROW_NUMBER()OVER(PARTITION BY s.EmailAddress
								  ORDER BY  b.EVENTDATE DESC, jb.JOBID DESC) as rnk 
	 FROM ENT._Subscribers s
	 JOIN _Bounce b ON b.SubscriberKey = s.SubscriberKey
	 JOIN _Job jb   ON jb.jobid = b.jobid
	WHERE lower(b.BounceCategory) = 'hard bounce'
	  AND b.EventDate >= DATEADD(m, -5, GetDate())
	  AND(LOWER(jb.emailName) like '%client%'
		  OR 
		  LOWER(jb.emailName) like '%animal%'
		  OR 
		  LOWER(jb.emailName) like '%equine%'
		  OR 
		  LOWER(jb.emailName) like '%cat%'
		  OR 
		  LOWER(jb.emailName) like '%dog%'
		  OR 
		  LOWER(jb.emailName) like '%feline%'
		  OR 
		  LOWER(jb.emailName) like '%canine%'
		  OR 
		  LOWER(jb.EmailSubject) like '%client%'
		  OR 
		  LOWER(jb.EmailSubject) like '%animal%'
		  OR 
		  LOWER(jb.EmailSubject) like '%equine%'
		  OR 
		  LOWER(jb.EmailSubject) like '%cat%'
		  OR 
		  LOWER(jb.EmailSubject) like '%dog%'
		  OR 
		  LOWER(jb.EmailSubject) like '%feline%'
		  OR 
		  LOWER(jb.EmailSubject) like '%canine%'
		  )
		AND LEN(Left(SubString(s.SubscriberKey, PatIndex('%[0-9.-]%', s.SubscriberKey), 8000), PatIndex('%[^0-9.-]%', SubString(s.SubscriberKey, PatIndex('%[0-9.-]%', s.SubscriberKey), 8000) + 'X')-1))!= 10 
	)w 
WHERE rnk = 1 