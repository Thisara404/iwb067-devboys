public type User record {|
    readonly int userId;
    string email;
    string password;
    string createdAt;
    string updatedAt;
|};

public type Chat record {|
    readonly int chatId;
    int userId;
    string role;  // Either "user" or "model"
    string text;
    string? img;  // Optional image field
    string createdAt;
|};

public type UserChat record {|
    readonly int id;
    int userId;
    int chatId;
    string title;
    string createdAt;
|};

public enum Role {
    USER = "user",
    MODEL = "model"
};
