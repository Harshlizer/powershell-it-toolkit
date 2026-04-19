SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.command,
    (su.user_objects_alloc_page_count * 8) / 1024 AS user_mb,
    (su.internal_objects_alloc_page_count * 8) / 1024 AS internal_mb
FROM sys.dm_db_session_space_usage su
JOIN sys.dm_exec_sessions s ON s.session_id = su.session_id
LEFT JOIN sys.dm_exec_requests r ON r.session_id = s.session_id
ORDER BY internal_mb DESC;
