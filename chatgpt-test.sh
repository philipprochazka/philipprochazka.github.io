$API_KEY = {foo/secret}

curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
  "model": "gpt-3.5-turbo",
  "prompt": "Say this is a test",
  "max_tokens": 7
}'
