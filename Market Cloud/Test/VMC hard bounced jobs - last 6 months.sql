 SELECT DISTINCT s.SubscriberKey    AS ID_EMAIL 
       , LOWER(s.EmailAddress)      AS EMAIL_ADDR  
       , b.BOUNCECATEGORY  
       , jb.JOBID 
       , jb.EMAILNAME  
       , CONVERT(b.EVENTDATE,Date)  AS DATE_BOUNCED
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
     --add start here 
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