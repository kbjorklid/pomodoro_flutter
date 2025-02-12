# Engineering conventions to use

## Code Organization

The directories under lib/ are organized by feature, each feature has its own directory and
is named according to the feature.

Also directly under lib/ there is a directory called 'core' which contains code that is shared across features.

Under each feature directory code is organised to four subdirectories in accordance to the clean architecture principles:
- **Presentation**: UI elements and presentation logic
- **Domain**: Domain entities, business logic, port and repository interfaces and
- **Application**: Application logic, use cases
- **Infrastructure**: Adapter and repository implementations for the interfaces defined in the domain layer

Under presentation directory, there is a subdirectory for riverpod providers. All providers of the feature must go here.
Providers may only be referred from the feature's presentation layer.

The following rules apply to code dependencies:

- **Presentation** may depend on **Domain**, **Application**, and **Infrastructure**
- **Application** may depend on **Domain**
- **Infrastructure** may depend on **Domain** and **Application**

Other dependencies are not allowed.

Here is an example of the directory structure, where 'timer' and 'settings' are features.

```
lib/
lib/core/
lib/core/presentation/
lib/core/presentation/providers/
lib/core/domain/
lib/core/application/
lib/timer/
lib/timer/presentation/
lib/timer/presentation/providers/
lib/timer/domain/
lib/timer/application/
lib/timer/infrastructure/
lib/settings/
lib/settings/presentation/
lib/settings/presentation/providers/
lib/settings/domain/
lib/settings/application/
lib/settings/infrastructure/
```

### Some additional rules
- StateNotifier classes should be in the **application** layer
- Providers should be in the **presentation** layer
- State classes used by StateNotifier classes should be in the **domain** layer

### Test code organization
- unit tests should go to /test/unit -directory
- Tests should have same directory structure as the code they are testing

## Layer principles

### Domain layer

- Entities should be immutable (use 'freezed' package)
- Value objects defined for value types, and should be immutable
- Value objects must validate values upon creation
- Define value objects even for simple types in order to leverage the type system. For example, use 'UserId' as primary key for a user instead of 'int'.
- Classes, enums etc should not be annotated with Hive annotations. Domain classes should be agnostic of the persistence
  mechanism.

### Application layer
- Use Case classes should be named "*UseCase". For example, "StartTimerUseCase"
- Use Case classes should have a single public method called either 'execute' or 'query', depending whether the use case is a command or a query.
- Use Case classes should have a single constructor that takes all dependencies as parameters.


## Coding Principles

- Use effective Dart style guide.
- Use SOLID principles.
- Use clean architecture principles.
- Use dependency injection.

Some specific coding principles to follow:

- Each provider should be in its own file.
- Prefer subclassing widgets and encapsulating logic in them.
- Prefer package-imports over relative imports.
- Write succinct class-level documentation comments for all classes, enums and such.

## Flutter Library choices

- Riverpod for state management and dependency injection
- Shared Preferences for storing user settings
- Hive for storing more complex data
- Mocktail for mocking
- 'logger' for logging
- 'golden_toolkit'
- 'go_router' for routing

# Git conventions

- Use conventional commits style commit messages

# Avoiding problems (LLM/Aider)

- Do not add a file called 'dart'.