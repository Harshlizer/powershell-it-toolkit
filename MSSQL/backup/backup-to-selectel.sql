USE [master];
GO

CREATE CREDENTIAL [s3://s3.ru-1.storage.selcloud.ru/<BUCKET_NAME>]
WITH IDENTITY = 'S3 Access Key',
SECRET = '<ACCESS_KEY_ID>:<SECRET_ACCESS_KEY>';
GO
