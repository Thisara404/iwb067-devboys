import ballerina/http;
import ballerina/sql;
// import ballerina/random;
import ballerina/time;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowMethods: ["GET", "POST", "OPTIONS"]
    },
    auth: [
        {
            jwtValidatorConfig: {
                issuer: "wso2",
                audience: "ballerina",
                signatureConfig: {
                    certFile: "resources/public.crt"
                }
            },
            scopes: ["admin"]
        }
    ]
}
service /api on new http:Listener(9090) {

    # Get all chats for a specific user
    isolated resource function get userchats/[int userId]() returns Chat[]|error {
        return selectChatsByUserId(userId);
    }

    # Get a specific chat by ID for a user
    isolated resource function get chats/[int userId]/[int chatId]() returns Chat|http:NotFound|http:InternalServerError {
        Chat|sql:Error chatEntry = selectChatByIdAndUser(chatId, userId);
        if chatEntry is Chat {
            return chatEntry;
        } else if (chatEntry is sql:NoRowsError) {
            return <http:NotFound>{body: {message: "Chat not found"}};
        } else {
            return <http:InternalServerError>{body: {message: "Error occurred while retrieving the chat"}};
        }
    }

    # Add a new chat for a user
    isolated resource function post chats/[int userId]() returns http:Created|http:InternalServerError {
        Chat newChat = {
            chatId: 1,
            role: "user",
            userId: userId,
            text: "New chat message",
            img: (),
            createdAt: string `${time:utcNow().toString()}`
        };

        sql:ExecutionResult|error result = insertChat(newChat);
        if isResultExtracted(result) {
            return <http:Created>{body: {message: "Chat added successfully"}};
        } else {
            return <http:InternalServerError>{body: {message: "Error occurred while adding the chat"}};
        }
    }

    # Get all user chats for a specific user
    isolated resource function get userchats/[int userId]/chats() returns UserChat[]|error {
        return selectUserChatsByUserId(userId);
    }

    # Register a new user
    isolated resource function post users(User userEntry) returns http:Created|http:InternalServerError {
        userEntry.createdAt = string `${time:utcNow().toString()}`;
        userEntry.updatedAt = userEntry.createdAt;

        sql:ExecutionResult|error result = insertUser(userEntry);
        if result is sql:ExecutionResult {
            return http:CREATED;
        } else {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    # User login
    isolated resource function post users/login(User userLogin) returns http:Ok|http:Unauthorized|error {
        User|sql:Error userEntry = check selectUserByEmail(userLogin.email);
        if userEntry is User {
            if userEntry.password == userLogin.password {
                return http:OK;
            } else {
                return <http:Unauthorized>{body: {message: "Invalid credentials"}};
            }
        } else {
            return <http:Unauthorized>{body: {message: "User not found"}};
        }
    }
}

isolated function isResultExtracted(sql:ExecutionResult|error result) returns boolean {
    if (result is sql:ExecutionResult) {
        return true;
    }
    return false;    
}
