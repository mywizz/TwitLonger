# TwitLonger

Simple wrapper for [TwitLonger](http://twitlonger.com)

## Requirement

- [TwitLonger developer registration](http://www.twitlonger.com/api)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- ARC

## Usage

	TwitLonger *twitlonger = [[TwitLonger alloc] initWithApplication:@"YOUR_APP_NAME" key:@"YOUR_API_KEY"];
	[twitlonger shorten:@"YOUR_LONG_TWEET"
               username:@"YOUR_TWITTER_SCREENNAME"
                success:(void(^)(id JSON)) {
         
					NSString *content = [JSON objectForKey:@"content"];
					NSLog(@"content : %@", content);
         
                } error:(void(^)(NSError *error)) {
         
					// Do something with error
         	
                }];

## License

Available under the MIT license.