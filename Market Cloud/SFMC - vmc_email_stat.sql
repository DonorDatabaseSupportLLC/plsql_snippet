SELECT Jobid
       , EmailName
       , DateSend
       , SUM(clicks)                     AS Clicked
       , SUM(formstack)                  AS formStackClick
       , SUM(opens)                      AS Opened
       , SUM(Bounces)                    AS HardBounce
       , SUM(unsubscribes)               AS Unsubscribed
       , COUNT(DISTINCT SubscriberKey)   AS TotalSent
FROM(SELECT s.SubscriberKey
            , s.jobid 
            , j.EmailName  
            , j.DeliveredTime                                     AS DateSend
            , CASE WHEN c.EventDate IS NOT NULL THEN 1 ELSE 0 END AS clicks
            , CASE WHEN o.EventDate IS NOT NULL THEN 1 ELSE 0 END AS opens
            , CASE WHEN b.EventDate IS NOT NULL THEN 1 ELSE 0 END AS Bounces
            , CASE WHEN u.EventDate IS NOT NULL THEN 1 ELSE 0 END AS unsubscribes
            , CASE WHEN d.EventDate IS NOT NULL THEN 1 ELSE 0 END AS formstack
            , row_number()over(partition BY s.SubscriberKey, j.jobid ORDER BY s.SubscriberKey) rnk 
       FROM _sent s 
       JOIN _job j              ON j.jobid = s.jobid 
       LEFT JOIN _click c       ON c.SubscriberKey = s.SubscriberKey 
                               AND c.jobid = s.jobid 
                               AND c.ListID  = s.ListID 
                               AND c.BatchID = s.BatchID 
                               AND c.IsUnique = '1' 
       LEFT JOIN _open o        ON o.SubscriberKey = s.SubscriberKey 
                               AND o.jobid = s.jobid 
                               AND o.ListID = s.ListID
                               AND o.BatchID  = s.BatchID 
                               AND o.IsUnique = '1'
       LEFT JOIN _bounce b      ON b.SubscriberKey = s.SubscriberKey  
                               AND b.jobid   = s.jobid 
                               AND b.ListID  = s.ListID
                               AND b.BatchID = s.BatchID
                               AND LOWER(b.bounceCategory) = 'hard bounce' 
                               AND b.IsUnique = '1'
       LEFT JOIN _unsubscribe u ON u.SubscriberKey = s.SubscriberKey
                               AND u.jobid = s.jobid 
                               AND u.ListID = s.ListID 
                               AND u.BatchID = s.BatchID 
                               AND u.IsUnique = '1'  
      LEFT JOIN _click d        ON d.SubscriberKey = s.SubscriberKey 
                               AND d.jobid = s.jobid 
                               AND d.ListID  = s.ListID 
                               AND d.BatchID = s.BatchID 
                               AND LOWER(d.URL) like '%formstack%'
                               AND d.IsUnique = '1' 
    WHERE s.EventDate BETWEEN DATEADD(m, -6, GetDate()) 
                          AND DATEADD(m, -5, GetDate())
      AND(LOWER(j.emailName) like '%client%'     OR 
          LOWER(j.emailName) like '%animal%'     OR 
          LOWER(j.emailName) like '%equine%'     OR 
          LOWER(j.emailName) like '%cat%'        OR 
          LOWER(j.emailName) like '%dog%'        OR 
          LOWER(j.emailName) like '%feline%'     OR 
          LOWER(j.emailName) like '%canine%'     OR 
          LOWER(j.EmailSubject) like '%client%'  OR 
          LOWER(j.EmailSubject) like '%animal%'  OR 
          LOWER(j.EmailSubject) like '%equine%'  OR 
          LOWER(j.EmailSubject) like '%cat%'     OR 
          LOWER(j.EmailSubject) like '%dog%'     OR 
          LOWER(j.EmailSubject) like '%feline%'  OR 
          LOWER(j.EmailSubject) like '%canine%'
          )
)w 
WHERE rnk = 1 
GROUP BY Jobid, EmailName, DateSend
