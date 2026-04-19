USE [master];
GO

CREATE CREDENTIAL [s3://storage.googleapis.com/<BUCKET_NAME>]
WITH IDENTITY = 'S3 Access Key',
SECRET = '<ACCESS_KEY_ID>:<SECRET_ACCESS_KEY>';
GO
