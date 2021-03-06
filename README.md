# aws-lambda-s3-sample

This sample was made with reference to the aws document.
It can create thumbnail image when image files putted on S3 bucket.

to reference [here](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-s3-example.html) if you want to know how to aws setting. 

this samples setting
```
IAM role: 
  lambda-s3-role
S3 bucket:
  lambda-s3-sample20190101
  lambda-s3-sample20190101resized
```

# Install

## 1. Copy site-packages from docker container

[pillow package](https://pillow.readthedocs.io/en/5.3.x/installation.html) for macOS unable to use in lambda.
so it has to use docker container.

```sh
# build docker image
docker build -t aws-lambda-s3-sample .

# create docker container and copy packages
docker create --name foo aws-lambda-s3-sample
docker cp foo:/usr/local/lib/python3.7/site-packages site-packages
docker rm foo

# remove docker image
docker rmi aws-lambda-s3-sample
```

## 2. Create zip file to deploy

```sh
cd ./site-packages
zip -r9 ../CreateThumbnail.zip .
cd -
zip -g CreateThumbnail.zip CreateThumbnail.py
```

## 3. run aws command

create lambda function

If time out error occured use s3 upload ([refs](https://stackoverflow.com/questions/48347520/the-write-operation-timed-out-in-lambda-update-function-code))

```sh
aws --debug lambda create-function \
--function-name CreateThumbnail \
--zip-file fileb://CreateThumbnail.zip \
--handler CreateThumbnail.handler \
--runtime python3.7 \
--role arn:aws:iam::<account-id>:role/lambda-s3-role \
--timeout 30 \
--memory-size 128
```

invoke (test) 
```sh
aws lambda invoke --function-name CreateThumbnail --invocation-type Event --payload file://inputfile.json outputfile.txt
```

add permission
```sh
aws lambda add-permission \
--function-name CreateThumbnail \
--principal s3.amazonaws.com \
--statement-id lambda-s3-sample-statement20190101 \
--action "lambda:InvokeFunction" \
--source-arn arn:aws:s3:::lambda-s3-sample20190101 \
--source-account <account-id>
```

<account-id> is here.(12 digit account id)
https://console.aws.amazon.com/support/home?#


# memo

update function
```
aws lambda update-function-code --function-name CreateThumbnail --zip-file fileb://CreateThumbnail.zip
```

remove permission
```sh
aws lambda remove-permission \
--function-name CreateThumbnail \
--statement-id lambda-s3-sample-statement20190101
```

get policy
```sh
aws lambda get-policy --function-name CreateThumbnail
```

Image upload to s3 bucket and  confirm thumbnail created.
```sh
$ aws s3 cp image.jpg s3://lambda-s3-sample20190101
upload: ./image.jpg to s3://lambda-s3-sample20190101/image.jpg

$ aws s3 ls s3://lambda-s3-sample20190101
2019-01-02 14:36:26    1444202 image.jpg

$ aws s3 ls s3://lambda-s3-sample20190101resized
2019-01-02 14:36:37     259610 image.jpg
```

delete image
```sh
aws s3 rm s3://lambda-s3-sample20190101/image.jpg
aws s3 rm s3://lambda-s3-sample20190101resized/image.jpg
```