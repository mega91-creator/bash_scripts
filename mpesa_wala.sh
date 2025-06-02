#!/bin/bash

# Correct credentials matching your uncommented Python code
BUSINESS_SHORTCODE="137146"
PASSKEY="42f400eaeec9b7f047ff2870f72332be7a582200c4f5fe888eebe6362aa3f3ea"
CONSUMER_KEY="yQAVZgGgDhMTqpWm6vHKkzjk4uqzEYw9"
CONSUMER_SECRET="gC91LGAZrM4PgGOp"

# Get current timestamp in YYYYMMDDHHmmss format
TIMESTAMP=$(date '+%Y%m%d%H%M%S')

# Calculate password - with NO extra whitespace
PASSWORD=$(echo -n "${BUSINESS_SHORTCODE}${PASSKEY}${TIMESTAMP}" | base64)

echo "Password encoding string: ${BUSINESS_SHORTCODE}${PASSKEY}${TIMESTAMP}"
echo "Encoded password: $PASSWORD"

# Get access token - improved parsing with full debugging
TOKEN_RESPONSE=$(curl -s "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials" \
  -H "Authorization: Basic $(echo -n ${CONSUMER_KEY}:${CONSUMER_SECRET} | base64)")

echo "Full token response: $TOKEN_RESPONSE"

# Extract token more reliably 
if command -v jq >/dev/null 2>&1; then
    TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
else
    TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | sed 's/"access_token":"//;s/"//')
fi

echo "Access Token: $TOKEN"

# Create temporary file for request payload
cat > request.json << EOF
{
  "BusinessShortCode": "${BUSINESS_SHORTCODE}",
  "Password": "${PASSWORD}",
  "Timestamp": "${TIMESTAMP}",
  "TransactionType": "CustomerBuyGoodsOnline",
  "Amount": 1,
  "PartyA": "254700716751",
  "PartyB": "${BUSINESS_SHORTCODE}",
  "PhoneNumber": "254700716751",
  "CallBackURL": "https://3563-41-60-233-14.ngrok-free.app/callback",
  "AccountReference": "Eastleigh mattreses - riverroad",
  "TransactionDesc": "Stk Test"
}
EOF

echo "Request payload:"
cat request.json

# Make STK Push request with verbose output
curl -v "https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @request.json

# Clean up
rm request.json