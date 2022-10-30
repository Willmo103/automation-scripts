# create a basic .gitignore
New-Item .gitignore
Write-Output /node_modules >> .gitignore
Write-Output /.vscode >> .gitignore
Write-Output /.idea >> .gitignore

Write-Output '{
  "name": "new express api",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "node ./frontend/app/index.js"
  },
  "author": "none",
  "license": "ISC",
  "dependencies": {
    "bcrypt": "^5.1.0",
    "bcryptjs": "^2.4.3",
    "express": "^4.18.2",
    "jsonwebtoken": "^8.5.1",
    "morgan": "^1.10.0",
    "pg": "^8.8.0",
    "sequelize": "^6.25.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}' > package.json

# init npm and install stuff
npm install

# create file structure
mkdir app
Set-Location ./app

# Create the Models folder
mkdir models

# Create a basic User Model
Write-Output 'const Sequelize = require("sequelize");
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
Write-Output 'const status = require("../utils/status");

exports.version = (req, res, next) => {
  return res.status(200).json({ API_version: "0.0.1" });
};
' > controllers/dev-controller.js

# User Controller
Write-Output 'const User = require("../models/user-model.js")
const {
  serverError,
  success,
  notFound,
  conflict,
  deleted,
  created,
  forbidden,
} = require("../utils/status");

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
      return res.status(404).json(notFound(`user with id "${req.params.idl}"`));
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
        .json(conflict(`user with email "${req.body.email}"`));
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
      return res.status(204).json(deleted(`user "${req.user.name}"`));
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
          .json(conflict(`user with email ${req.body.email} `));
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
Write-Output 'const { compare } = require("bcrypt");
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
Write-Output 'const {
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
Write-Output 'const { version } = require("../controllers/dev-controller");
const router = require("express").Router();

router.get("/version", version);

module.exports = router;
' > routers/dev-router.js

# Login Router
Write-Output 'const router = require("express").Router();
const { loginUser } = require("../controllers/login-controller");

router.post("/", loginUser);

module.exports = router;
' > routers/login-router.js

# Create the Utils dir
mkdir utils

# some utility functuons for hashing our passwords
Write-Output 'const { compare, hash } = require("bcrypt");
const User = require("../models/user-model");

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
Write-Output 'const Sequelize = require("sequelize").Sequelize;

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
Write-Output 'class Status {
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
      status: "204 - NO CONTENT",
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
Write-Output 'const { unauthorized, forbidden } = require("../utils/status");

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
Write-Output 'const express = require("express");
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
app.use("/dev", require("./routers/dev-router"))
// Users
app.use("/user", require("./routers/user-router"))
//login
app.use("/login", require("./routers/login-router"))

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

Set-Location ../

Write-Output 'FROM node:14

EXPOSE 5000

WORKDIR /src

RUN npm install npm@latest -g

COPY package.json package-lock*.json ./

RUN npm install

COPY . .

CMD [ "node", "app/index.js"]

' > Dockerfile

Write-Output 'version: "3.8"

services:
  express_api:
    container_name: New_API
    image: new-api_0.0.1
    build:
      context: .
    ports: ["5000:5000"]
    environment:
      - EXTERNAL_PORT=5000
      - PGDATABASE=new_db
      - PGUSER=user
      - PGPASSWORD=12345
      - PGHOST=new_db
      - TOKEN_KEY=Token-Key12345
      - EXPIRE_TIME=1h
  new_db:
    container_name: new_db
    image: "postgres:12"
    ports: ["5432:5432"]
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=12345
      - POSTGRES_DB=new_db
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data: {}
' > docker-compose.yml

Write-Output "installation done. run 'docker-compose' to spin up database."


