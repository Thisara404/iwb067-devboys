import ballerinax/mysql;
import ballerina/sql;
// import ballerinax/mysql.driver as _;

// Configurable variables
configurable string HOST = ?;
configurable int PORT = ?;
configurable string USERNAME = ?;
configurable string PASSWORD = ?;
configurable string DATABASE = ?;

// Client options configuration (if needed)
configurable mysql:Options & readonly connectionOptions = {};

// Initialize the MySQL client
mysql:Client|sql:Error dbClientResult = new (HOST, USERNAME, PASSWORD, DATABASE, PORT);

// Ensure dbClient is correctly initialized
 final mysql:Client dbClient = check dbClientResult;

# Insert a new user into the database
isolated function insertUser(User entry) returns sql:ExecutionResult|error {
    User {userId, email, password, createdAt, updatedAt} = entry;
    sql:ParameterizedQuery insertQuery = `INSERT INTO users (id, email, password, createdAt, updatedAt) 
                                          VALUES (${userId}, ${email}, ${password}, ${createdAt}, ${updatedAt})`;
    return dbClient->execute(insertQuery);
}

# Select a user by ID
isolated function selectUserById(int id) returns User|sql:Error {
    sql:ParameterizedQuery selectQuery = `SELECT * FROM users WHERE id = ${id}`;
    return dbClient->queryRow(selectQuery);
}

# Select a user by email (for login)
isolated function selectUserByEmail(string email) returns User|sql:Error {
    sql:ParameterizedQuery selectQuery = `SELECT * FROM users WHERE email = ${email}`;
    return dbClient->queryRow(selectQuery);
}

# Insert a new chat into the database
isolated function insertChat(Chat entry) returns sql:ExecutionResult|error {
    Chat {chatId, userId, role, text, img, createdAt} = entry;
    sql:ParameterizedQuery insertQuery = `INSERT INTO chats (id, userId, role, text, img, createdAt) 
                                          VALUES (${chatId}, ${userId}, ${role}, ${text}, ${img}, ${createdAt})`;
    return dbClient->execute(insertQuery);
}

# Select a chat by ID and userId
isolated function selectChatByIdAndUser(int id, int userId) returns Chat|sql:Error {
    sql:ParameterizedQuery selectQuery = `SELECT * FROM chats WHERE id = ${id} AND userId = ${userId}`;
    return dbClient->queryRow(selectQuery);
}

# Select all chats for a user
isolated function selectChatsByUserId(int userId) returns Chat[]|error {
    sql:ParameterizedQuery selectQuery = `SELECT * FROM chats WHERE userId = ${userId}`;
    stream<Chat, error?> chatStream = dbClient->query(selectQuery);
    return from Chat chat in chatStream select chat;
}

# Insert a new user chat entry into the database
isolated function insertUserChat(UserChat entry) returns sql:ExecutionResult|error {
    UserChat {id, userId, chatId, title, createdAt} = entry;
    sql:ParameterizedQuery insertQuery = `INSERT INTO user_chats (id, userId, chatId, title, createdAt) 
                                          VALUES (${id}, ${userId}, ${chatId}, ${title}, ${createdAt})`;
    return dbClient->execute(insertQuery);
}

# Select all user chats by userId
isolated function selectUserChatsByUserId(int userId) returns UserChat[]|error {
    sql:ParameterizedQuery selectQuery = `SELECT * FROM user_chats WHERE userId = ${userId}`;
    stream<UserChat, error?> userChatStream = dbClient->query(selectQuery);
    return from UserChat userChat in userChatStream select userChat;
}
