# create a basic .gitignore
echo /node_modules > .gitignore
echo /.vscode >> .gitignore
echo /.idea >> .gitignore
echo .env >> .gitignore

# init npm and install stuff
npm init -y
npm install express jsonwebtoken morgan pg sequelize bcrypt bcryptjs

# create file structure
mkdir app
cd ./app

# Create the Models folder
mkdir models

# Create a basic User Model
echo 'const Sequelize = require("sequelize");
const db = require("../utils/database");

const User = db.define("users", {
  id: {
    type: Sequelize.INTEGER,
    autoIncrement: true,
    allowNull: false,
    primaryKey: true,
  },
  username: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true,
  },
  email: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true,
  },
  password: {
    type: Sequelize.STRING,
    allowNull: false,
  },
});

module.exports = User;
' > models/user-model.js

# Create the Controllers dir
mkdir controllers

# Dev Controller
echo 'const status = require("../utils/status");

exports.version = (req, res, next) => {
  return res.status(200).json({ API_version: "0.0.1" });
};
' > controllers/dev-controller.js

# User Controller
echo 'const User = require("../models/user-model.js")
const {
  serverError,
  success,
  notFound,
  conflict,
  deleted,
  created,
  forbidden,
} = require("../utils/status");
const { buildNewUserModel } = require("../utils/utils")
const { Op } = require("sequelize");

exports.getSelf = async (req, res, next) => {
  try {
    const user = await User.findOne({
      where: { username: req.user.name },
      attributes: { exclude: ["createdAt", "updatedAt", "id"] },
    });
    return res.status(200).json(success(user));
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};


exports.getOneUser = async (req, res, next) => {
  try {
    const user = await User.findOne({
      where: { id: req.params.id },
      attributes: {
        exclude: [
          "password",
          "email",
          "updatedAt",
        ],
      },
    });
    if (!user) {
      return res.status(404).json(notFound(`user with id (${req.params.id})`));
    }
    return res.status(200).json(success(user));
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};

exports.createOneUser = async (req, res, next) => {
  try {
    const verifyUser = await User.findOne({
      where: { email: req.body.email },
    });
    if (verifyUser) {
      return res
        .status(409)
        .json(conflict(`user with email (${req.body.email})`));
    }
    try {
      const USER_MODEL = await buildNewUserModel(req.body);
      try {
        const user = await User.create(USER_MODEL);
        return res.status(201).json(created(user));
      } catch (error) {
        return res.status(500).json(serverError(error));
      }
    } catch (error) {
      return res.status(500).json(serverError(error));
    }
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};

exports.deleteOneUser = async (req, res, next) => {
  try {
    const verifyUser = await User.findOne({
      where: { username: req.user.name, id: req.params.id },
    });
    if (!verifyUser) {
      return res
        .status(403)
        .json(forbidden("this account does not belong to you."));
    }
    try {
      const user = await User.destroy({
        where: {
          id: req.params.id,
          username: req.user.name,
        },
      });
      return res.status(200).json(deleted(`user (${req.user.name})`));
    } catch (error) {
      return res.status(500).json(serverError(error));
    }
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};

exports.updateOneUser = async (req, res, next) => {
  try {
    const verifyUser = await User.findOne({
      where: { username: req.user.name, id: req.params.id },
    });
    if (!verifyUser) {
      return res
        .status(403)
        .json(forbidden("this account does not belong to you."));
    }
    try {
      const verifyUserEmail = await User.findOne({
        where: { email: req.body.email, id: { [Op.ne]: `${req.params.id}` } },
      });
      if (verifyUserEmail) {
        return res
          .status(409)
          .json(conflict(`user with email (${req.body.email}) `));
      }
      const USER_MODEL = buildNewUserModel(req.body);
      try {
        const user = await User.update(USER_MODEL, {
          where: {
            id: req.params.id,
            username: req.user.name,
          },
        });
        return res.status(200).json(success(user));
      } catch (error) {
        return res.status(500).json(serverError(error));
      }
    } catch (error) {
      return res.status(500).json(serverError(error));
    }
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};
' > controllers/user-controller.js

# Add logic for users to log in
echo 'const { compare } = require("bcrypt");
const User = require("../models/user-model");
const sign = require("jsonwebtoken").sign;
const { jwtToken, badLogin, serverError } = require("../utils/status");

exports.loginUser = async (req, res) => {
  try {
    //   look for either username or email in body
    const user = await User.findOne({
      where: {
        email: req.body.email,
      },
    });
    try {
      // compare the req password with the hashed database password
      const match = await compare(req.body.password, user.password);
      if (match) {
        //   generate jwt from username
        const token = sign(
          {
            name: user.username,
          },
          process.env.TOKEN_KEY,
          {
            expiresIn: process.env.EXPIRE_TIME,
          }
        );
        // return token
        return res.status(200).json(jwtToken(token));
      }
    } catch (error) {
      return res.status(400).json(badLogin());
    }
  } catch (error) {
    return res.status(500).json(serverError(error));
  }
};
' > controllers/login-controller.js

# Create the Routers dir
mkdir routers

# User Router
echo 'const {
  getSelf,
  getOneUser,
  createOneUser,
  updateOneUser,
  deleteOneUser,
} = require("../controllers/user-controller");
const oauth = require("../utils/0auth2").authorize;

const router = require("express").Router();

router
  .get("/", oauth, getSelf)
  .get("/:id", oauth, getOneUser)
  .post("/", createOneUser)
  .put("/:id", oauth, updateOneUser)
  .delete("/:id", oauth, deleteOneUser)

module.exports = router;
' > routers/user-router.js

# Dev Router
echo 'const { version } = require("../controllers/dev-controller");
const router = require("express").Router();

router.get("/version", version);

module.exports = router;
' > routers/dev-router.js

# Login Router
echo 'const router = require("express").Router();
const { loginUser } = require("../controllers/login-controller");

router.post("/", loginUser);

module.exports = router;
' > routers/login-router.js

# Create the Utils dir
mkdir utils

# some utility functuons
echo 'const User = require("../models/user-model");
const { compare, hash } = require("bcrypt");

exports.checkHashedPassword = async (reqPassword, storedPassword) => {
  try {
    const validPassword = await compare(reqPassword, storedPassword);
    return validPassword;
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};

exports.hashPassword = async (password) => {
  try {
    const encryptedPassword = await hash(password, 10);
    return encryptedPassword;
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};

exports.buildNewUserModel = async (body = {}) => {
  try {
    const hashed = await this.hashPassword(body.password);
    const USER_MODEL = {
      username: body.username,
      email: body.email,
      password: hashed,
    };
    return USER_MODEL;
  } catch (error) {
    console.log(error);
    return;
  }
};
' > utils/utils.js

# Create Our Database connection to our docker database instance
echo 'const Sequelize = require("sequelize").Sequelize;

const sequelize = new Sequelize(
  process.env.PGDATABASE,
  process.env.PGUSER,
  process.env.PGPASSWORD,
  {
    host: process.env.PGHOST,
    dialect: "postgres",
  }
);

module.exports = sequelize;
' > utils/database.js

# A class I wrote to standardize responses
echo 'class Status {
  constructor() {}
  serverError = (error) => {
    console.log(error);
    return {
      status: "500 - INTERNAL SERVER ERROR",
      details: error,
    };
  };

  notFound = (item) => {
    return {
      status: "404 - NON FOUND",
      details: `${item} does not exist.`,
    };
  };

  conflict = (item) => {
    return {
      status: "409 - CONFLICT",
      details: `${item} already exists.`,
    };
  };

  deleted = (item) => {
    return {
      status: "200 - SUCCESS",
      details: `${item} successfully deleted.`,
    };
  };

  empty = (data) => {
    return {
      status: "200 - SUCCESS",
      details: "currently nothing to show",
      data: data,
    };
  };

  success = (data) => {
    return {
      status: "200 - SUCCESS",
      data: data,
    };
  };

  jwtToken = (token) => {
    return {
      status: "200 - SUCCESS",
      "token-type": "Bearer",
      token: token,
    };
  };

  badLogin = () => {
    return {
      status: "400 - BAD REQUEST",
      details: "Invalid credentials. Unable to login",
    };
  };

  created = (data) => {
    return {
      status: "201 - CREATED",
      details: "created new resource",
      data: data,
    };
  };

  unauthorized = () => {
    return {
      status: "401 - UNAUTHORIZED ACCESS",
      details: `Not authorized. Please Login.`,
    };
  };

  forbidden = (error) => {
    return {
      status: "403 - FORBIDDEN",
      details: `Not authorized. Please Login.`,
      error: error,
    };
  };
}

const status = new Status();
module.exports = status;
' > utils/status.js

# Create 0auth2 logic
echo 'const { unauthorized, forbidden } = require("../utils/status");

const jwt = require("jsonwebtoken");

exports.authorize = (req, res, next) => {
  //   get the auth header and cut off the "Bearer"
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  // check token not null
  if (!token) {
    return res.status(401).json(unauthorized());
  }
  // verify
  jwt.verify(token, process.env.TOKEN_KEY, (err, user) => {
    if (err) {
      return res.status(403).json(forbidden(err));
    }
    // set user and pass it
    req.user = user;
    next();
  });
};
' > utils/0auth2.js

# Create Index.js file
touch index.js
echo 'const express = require("express");
const morgan = require("morgan");
const sequelize = require("./utils/database");

// Initialize App
const app = express();

// Config
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(morgan("common"));
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET", "PUT", "POST", "DELETE");
  next();
});

// Dev
app.use("/dev", require("./routers/dev-router"));
// Users
app.use("/user", require("./routers/user-router"));
//login
app.use("/login", require("./routers/login-router"));

// function to creates new tables on startup
(async () => {
  try {
    console.log("Creating Tables....");
    await sequelize.sync({ force: false });
    console.log("Tables Created!");
    app.listen(process.env.EXTERNAL_PORT || 5000, () => {
      console.log("Server Listening: http://localhost:5000");
    });
  } catch (error) {
    console.log("Error! Unable to build database: ", error);
  }
})();
' > index.js

cd ../

echo 'FROM node:14

EXPOSE 5000

WORKDIR /src

RUN npm install npm@latest -g

COPY package.json package-lock*.json ./

RUN npm install

COPY . .

CMD [ "node", "app/index.js"]

' > Dockerfile

echo 'version: "3.8"

services:
  express_API:
    container_name: express_API
    image: new-api_0.0.1
    build:
      context: .
    ports: ["5000:5000"]
    environment:
      - EXTERNAL_PORT=5000
      - PGDATABASE=express_database
      - PGUSER=user
      - PGPASSWORD=12345
      - PGHOST=express_database
      - TOKEN_KEY=Token-Key12345
      - EXPIRE_TIME=1h
  express_database:
    container_name: express_database
    image: "postgres:12"
    ports: ["5432:5432"]
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=12345
      - POSTGRES_DB=express_database
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data: {}
' > docker-compose.yml

echo '{
        "info": {
                "_postman_id": "9301ee75-49e1-4cb1-83ee-7a594f848623",
                "name": "New Express API Requests",
                "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
                "_exporter_id": "22094285"
        },
        "item": [
                {
                        "name": "login",
                        "event": [
                                {
                                        "listen": "test",
                                        "script": {
                                                "exec": [
                                                        "pm.collectionVariables.set(\"JWT\", pm.response.json().token);\r",
                                                        "console.log(pm.response.json().token)"
                                                ],
                                                "type": "text/javascript"
                                        }
                                }
                        ],
                        "request": {
                                "method": "POST",
                                "header": [],
                                "body": {
                                        "mode": "raw",
                                        "raw": "{\r\n    \"email\": \"william@email.com\",\r\n    \"password\": \"1234567890\"\r\n}",
                                        "options": {
                                                "raw": {
                                                        "language": "json"
                                                }
                                        }
                                },
                                "url": {
                                        "raw": "{{URL}}/login",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "login"
                                        ]
                                }
                        },
                        "response": []
                },
                {
                        "name": "Create User",
                        "request": {
                                "method": "POST",
                                "header": [],
                                "body": {
                                        "mode": "raw",
                                        "raw": "{\r\n    \"username\": \"william\",\r\n    \"email\": \"william@email.com\",\r\n    \"password\": \"1234567890\" \r\n}",
                                        "options": {
                                                "raw": {
                                                        "language": "json"
                                                }
                                        }
                                },
                                "url": {
                                        "raw": "{{URL}}/user/",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "user",
                                                ""
                                        ]
                                }
                        },
                        "response": []
                },
                {
                        "name": "Get User Self",
                        "request": {
                                "method": "GET",
                                "header": [],
                                "url": {
                                        "raw": "{{URL}}/user",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "user"
                                        ]
                                }
                        },
                        "response": []
                },
                {
                        "name": "Get User by ID",
                        "request": {
                                "method": "GET",
                                "header": [],
                                "url": {
                                        "raw": "{{URL}}/user/:id",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "user",
                                                ":id"
                                        ],
                                        "variable": [
                                                {
                                                        "key": "id",
                                                        "value": "5"
                                                }
                                        ]
                                }
                        },
                        "response": []
                },
                {
                        "name": "Update User",
                        "request": {
                                "method": "PUT",
                                "header": [],
                                "body": {
                                        "mode": "raw",
                                        "raw": "{\r\n        \"username\": \"william\",\r\n        \"email\": \"will@email.com\",\r\n        \"password\": \"1234567890\"\r\n}",
                                        "options": {
                                                "raw": {
                                                        "language": "json"
                                                }
                                        }
                                },
                                "url": {
                                        "raw": "{{URL}}/user/2",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "user",
                                                "2"
                                        ]
                                }
                        },
                        "response": []
                },
                {
                        "name": "Delete User",
                        "request": {
                                "method": "DELETE",
                                "header": [],
                                "body": {
                                        "mode": "raw",
                                        "raw": "",
                                        "options": {
                                                "raw": {
                                                        "language": "json"
                                                }
                                        }
                                },
                                "url": {
                                        "raw": "{{URL}}/user/:id",
                                        "host": [
                                                "{{URL}}"
                                        ],
                                        "path": [
                                                "user",
                                                ":id"
                                        ],
                                        "variable": [
                                                {
                                                        "key": "id",
                                                        "value": "1"
                                                }
                                        ]
                                }
                        },
                        "response": []
                }
        ],
        "auth": {
                "type": "bearer",
                "bearer": [
                        {
                                "key": "token",
                                "value": "{{JWT}}",
                                "type": "string"
                        }
                ]
        },
        "event": [
                {
                        "listen": "prerequest",
                        "script": {
                                "type": "text/javascript",
                                "exec": [
                                        ""
                                ]
                        }
                },
                {
                        "listen": "test",
                        "script": {
                                "type": "text/javascript",
                                "exec": [
                                        ""
                                ]
                        }
                }
        ],
        "variable": [
                {
                        "key": "JWT",
                        "value": "",
                        "type": "string"
                },
                {
                        "key": "URL",
                        "value": "http://localhost:5000",
                        "type": "string"
                }
        ]
}' > new_express_api.postman_collection.json

echo 'express_api.postman_collection.json
node_modules
.git
.gitignore
' > .dockerignore

echo "Installation complete!

To start up your new Express API run the command

  '$ docker-compose build && docker-compose up'

from the project directory to build your images and
startup the project.

**It's reccomended that you change the enviornment
variables in the 'docker-compose.yml' file for security.**

Import the included Postman collection:

    './new_express_api.postman_collection.json'

into your Postman app to have instant access to the
preset requests for this API.

Happy Coding,

  -Will Morris"
