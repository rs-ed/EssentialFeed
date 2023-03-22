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

### Cache Feed Use Case
