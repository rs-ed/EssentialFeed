#  Essential Feed Exercise

[![CI](https://github.com/rs-ed/EssentialFeed/actions/workflows/CI.yml/badge.svg)](https://github.com/rs-ed/EssentialFeed/actions/workflows/CI.yml)

## Use Cases

### Load Feed From Cache Use Case

#### Primary course:

1. Execute "Load Image Feed' command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Retrieval error course (sad path):

1. System delivers error.

#### Expired cache course (sad path):

1. System delivers no feed images.

#### Empty cache course (sad path):

1. System delivers no feed images.


### Validate Feed Cache Use Case

#### Primary course:

1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.

#### Retrieval error course (sad path):

1. System deletes cache.

#### Expired cache course (sad path):

1. System deletes cache.


### Codable feed store

- Retrieve
  - Empty cache returns empty
  - Empty cache twice returns empty (no side-effects)
  - Non-empty cache returns data
  - Non-empty cache twice returns same data (no side-effects)
  - Error (if applicable, e.g., invalid data)
  - Error twice returns same error (if applicable, e.g., invalid data)

- Insert
  - To empty cache stores data
  - To non-empty cache overrides previous data with new data
  - Error (if applicable, e.g., no write permission)

- Delete
  - Empty cache does nothing (cache stays empty and does not fail)
  - Non-empty cache leaves cache empty
  - Error (if applicable, e.g., no delete permission)

- Side-effects must run serially to avoid race-conditions
