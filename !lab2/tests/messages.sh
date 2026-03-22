echo "Send message"
curl -X POST http://localhost:8084/messages \
-H "Authorization: Bearer 123" \
-d '{"from":1,"to":2,"text":"hi"}'
echo -e "\n"

echo "Get messages"
curl "http://localhost:8084/messages?user_id=1" \
-H "Authorization: Bearer 123"
echo -e "\n"