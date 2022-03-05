# aniwatch
An app that replicates what ani-cli does.
A browser tool that scrapes gogoanime.
A android app based on https://github.com/pystardust/ani-cli 

# Notes for the developer

## Directory Structure we are going for
```
--lib
  |--screens
  |--utils
  |--widgets
  |--services
  |--data
  |-- ...
```

* **Screens**: This folder will contain the application UI files rendered on the device screen.

* **Utils**: This folder contains the functions used to implement the application’s business logic. For instance, if we build a social media application that supports a multi-account login, the utilities will ensure that the data rendered is changed according to the currently logged-in account.

* **Widgets**: This folder contains widgets that are used repeatedly in the application. If you are using an API to list GitHub accounts following a particular user, the followers’ list view remains the same. Only the data that is rendered is dynamic. In such a case, we will use the followers widget in our widgets folder.

* **Models** This folder holds DAO classes.

* **Services**: Services folder should handle your application’s networking logic. For example, once a user gets authenticated with Google or GitHub, the application needs to update the backend with the access token. The service folder will contain the implementation of the logic responsible for handling this functionality.
