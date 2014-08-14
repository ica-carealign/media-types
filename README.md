media-types
===========

A multi-platform collection of objects describing [IANA-registered Media Types](http://www.iana.org/assignments/media-types/media-types.xhtml).

## Tasks

### Save IANA Data to Cache

```bash
$ rake cache
```

### Load New Data from IANA

```bash
$ rake load
```

### Generate Objects from Cache

```bash
$ rake generate
```

### Load New Data, Save to Cache, and Generate Objects

```bash
$ rake generate_fresh
```
