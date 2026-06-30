#!/bin/bash

# ==============================================================================
# AWS Academy Credentials
# Copy the values from AWS Details > Learner Lab, then source this file:
#   source 00-export_vars.sh
# ==============================================================================

export AWS_ACCESS_KEY_ID="ASIARXKOG3MYFSQMMOZN"
export AWS_SECRET_ACCESS_KEY="OsEiDWDWmGZ0+UgtBrZJ/QJJ+i3fONnSHvwubanw"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEPP//////////wEaCXVzLXdlc3QtMiJHMEUCIHeD8UTC0I8lEK2OAOTcsQOojatsshyivX0jhpQoL74rAiEAhk0PpQK7YjQd7c+jhcEMZA2kbvZvEIiUnvN29zRyE74qvAIIvP//////////ARAAGgwxMTg4MTI0OTg3MzYiDBAMihvkcZyjGZ9hfSqQAvWaw/WtiEewOJFy5ifVz4pw91eP1DkNx1tXJJS3xtYRtuv1w3LiNbzffgwOCku/8LkfOevaxGLqK/ETeCIzcmVAda2RZqRnB6aYKnesf961KC8+vhTWPoMeW9AXKUkmlPe6BAvEYKG6RPtYLEucntRUKtRkNm5LHX6l3bs81V3WTx9Zy4i2NZ0A0tZh5Has6YncuA1x+Ygbf+4AzZ7XuAHuERKKWQBx12PCl664JaWiJWZtiOFxCkHY5TW1CqRut8v2ZF1VzjKP0yB7ylO20mnjrWsVSOp/DshRX8ygl7yZ0zpDL6vYxIQHNikSQlCWCURAE59C1cz9Yld2j7UCB6fKtpmtR5DCBY7T+1Qs8v5wMM/hjNIGOp0Bn78RZyUbssQLOeB/rRC4i5snby8bgzxG/zp07pU6oLLtNc2Q7Q2ZGu8HwKQ6S7O6dEQbnoP6+ydWIdclJUtDuTDi3aEAlX8YX+2lX/BqidT18Fggu0iR2MGmT5BetDfEIt1SsqTzW0iXG5FBjY1l1tcbwc0uMnsrB78GrcBVFGK277wVJS8ItroJ57oQ5RWN2HXyaf2YZ36Z6t8o6Q=="

# After terraform apply, connect to the cluster with:
#   aws eks update-kubeconfig --region us-east-1 --name tienda-eks
#
# Authenticate Docker with ECR:
#   aws ecr get-login-password --region us-east-1 \
#     | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
