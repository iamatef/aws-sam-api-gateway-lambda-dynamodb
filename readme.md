## AWS API Gateway & Lambda & DynamoDB table using SAM

This SAM project creates a new lambda function, API Gateway to trigger this lambda & DynamoDB table to store the date the lambda will return.

### Steps

#### 1. **Create a New Template File**

Create a new file called `template.yaml` in the root of your project. this file will contain the AWS SAM syntax in YAML format.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: 'AWS::Serverless-2016-10-31'
Description: A starter AWS Lambda function.
Resources:
  helloworldpython3:
    Type: 'AWS::Serverless::Function'
    Properties:
      Handler: app.lambda_handler
      Runtime: python3.9
      CodeUri: src/
      Description: A starter AWS Lambda function.
      MemorySize: 128
      Timeout: 3
      Environment:
        Variables:
          TABLE_NAME: !Ref Table
          REGION_NAME: !Ref AWS::Region           
      Events:
        HelloWorldAPISam:
          Type: Api
          Properties:
            Path: /hello
            Method: GET 
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref Table
  Table:
    Type: AWS::Serverless::SimpleTable
    Properties:
      PrimaryKey: 
        Name: greeting
        Type: String
      ProvisionedThroughput: 
        ReadCapacityUnits: 2
        WriteCapacityUnits: 2
```

#### 2. **Create a New Folder**

Create a new folder called `src` in the root of your project. this folder will contain the source code of your lambda function.

#### 3. **Create a New File**

Create a new file called `app.py` in the `src` folder. this file will contain the source code of your lambda function.

```python
import boto3
import json
import os

print('Loading function')

# Create the client for DynamoDB outside the hander so it can be reused
region_name = os.environ['REGION_NAME']
dynamo = boto3.client('dynamodb', region_name=region_name)
table_name = os.environ['TABLE_NAME']
 
def respond(err, res=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(res),
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def lambda_handler(event, context):
    scan_result = dynamo.scan(TableName=table_name)
    return respond(None,  res = scan_result['Items'])
    
```

#### 4. **Package**

Package the SAM template using the `sam package` command. This command will upload the local artifacts of your application to the S3 bucket you specify and output a new template that refers to the artifacts in S3.

```bash
aws cloudformation package --template-file template.yaml --s3-bucket atef-code-sam --output-template-file packaged.yaml
```

#### 5. **Deploy**

Deploy the packaged template using the `sam deploy` command. This command will create a Cloudformation Stack and deploy your SAM resources.

```bash
aws cloudformation deploy --template-file packaged.yaml --stack-name atef-sam-stack --capabilities CAPABILITY_IAM
```