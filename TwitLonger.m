// TwitLonger.m
//
// Copyright (c) 2012 Yunseok Kim (http://mywizz.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TwitLonger.h"
#import "AFNetworking.h"

NSString * const kTwitLongerBaseURL = @"http://www.twitlonger.com";
NSString * const kTwitLongerErrorDomain = @"com.twitlonger.TwitLonger";

@implementation TwitLonger

// ---------------------------------------------------------------------
#pragma mark -

- (id)initWithApplication:(NSString *)app key:(NSString *)key
{
	self = [super init];
	if (self)
	{
		self.appName = [NSString stringWithString:app];
		self.apiKey = [NSString stringWithString:key];
	}
	return self;
}

// ---------------------------------------------------------------------
#pragma mark -

- (void)shorten:(NSString *)tweet
       username:(NSString *)username
        success:(void (^)(id result))successBlock
          error:(void (^)(NSError *error))errorBlock
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:4];
	[parameters setObject:self.apiKey forKey:@"api_key"];
	[parameters setObject:self.appName forKey:@"application"];
	[parameters setObject:username forKey:@"username"];
	[parameters setObject:tweet forKey:@"message"];
	
	AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kTwitLongerBaseURL]];
	NSURLRequest *request = [client requestWithMethod:@"POST" path:@"/api_post" parameters:parameters];
	
	AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLDocument *document) {
		
		NSError *parseError;

		NSArray *errors = [document nodesForXPath:@"//error/text()" error:&parseError];
		if (parseError)
		{
			errorBlock(parseError);
			return;
		}
		
		if (errors.count)
		{
			NSError *xmlError = [NSError errorWithDomain:kTwitLongerErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:[errors lastObject] forKey:NSLocalizedDescriptionKey]];
			errorBlock(xmlError);
			return;
		}
		
		NSArray *contents = [document nodesForXPath:@"//post/content/text()" error:&parseError];
		if (parseError)
		{
			errorBlock(parseError);
			return;
		}
		
		if (contents.count == 0)
		{
			NSError *noContentError = [NSError errorWithDomain:kTwitLongerErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:[document XMLString] forKey:NSLocalizedDescriptionKey]];
			errorBlock(noContentError);
			return;
		}

		NSDictionary *result = [NSDictionary dictionaryWithObject:[[contents lastObject] XMLString] forKey:@"content"];
		successBlock(result);
		
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLDocument *document) {
		
		errorBlock(error);
		
	}];
	
	[operation start];
}

@end