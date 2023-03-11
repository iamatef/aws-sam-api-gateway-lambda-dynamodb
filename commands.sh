 #create s3 bucket 
aws s3 mb s3://atef-code-sam

#package the code
aws cloudformation package --template-file template.yaml --s3-bucket atef-code-sam --output-template-file packaged.yaml

#deploy the code
aws cloudformation deploy --template-file packaged.yaml --stack-name atef-sam-stack --capabilities CAPABILITY_IAM
