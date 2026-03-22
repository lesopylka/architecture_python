echo "Create user"
curl -X POST http://localhost:8082/users \
-d '{"login":"alice"}'
echo -e "\n"

echo "Get users"
curl http://localhost:8082/users
echo -e "\n"

echo "Find by login"
curl "http://localhost:8082/users?login=alice"
echo -e "\n"