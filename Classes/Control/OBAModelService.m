#import "OBAModelService.h"
#import "OBAModelServiceRequest.h"
#import "UIDeviceExtensions.h"
#import "OBASearchController.h"
#import "OBASphericalGeometryLibrary.h"


static const float kSearchRadius = 400;


@interface OBAModelService (Private)

- (OBAModelServiceRequest*) request:(NSString*)url args:(NSString*)args selector:(SEL)selector delegate:(id<OBAModelServiceDelegate>)delegate context:(id)context;
- (OBAModelServiceRequest*) request:(OBAJsonDataSource*)source url:(NSString*)url args:(NSString*)args selector:(SEL)selector delegate:(id<OBAModelServiceDelegate>)delegate context:(id)context;
- (CLLocation*) currentOrDefaultLocationToSearch;
- (NSString*) escapeStringForUrl:(NSString*)url;

@end


@implementation OBAModelService

@synthesize modelDao = _modelDao;
@synthesize modelFactory = _modelFactory;
@synthesize references = _references;
@synthesize obaJsonDataSource = _obaJsonDataSource;
@synthesize googleMapsJsonDataSource = _googleMapsJsonDataSource;
@synthesize locationManager = _locationManager;

- (void) dealloc {
	[_references release];
	[_modelDao release];
	[_modelFactory release];
	[_obaJsonDataSource release];
	[_googleMapsJsonDataSource release];
	[_locationManager release];
	[super dealloc];
}

- (id<OBAModelServiceRequest>) requestStopForId:(NSString*)stopId withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {

	NSString * url = [NSString stringWithFormat:@"/api/where/stop/%@.json", stopId];
	NSString * args = @"version=2";
	SEL selector = @selector(getStopFromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestStopWithArrivalsAndDeparturesForId:(NSString*)stopId withMinutesAfter:(NSUInteger)minutesAfter withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {

	NSString *url = [NSString stringWithFormat:@"/api/where/arrivals-and-departures-for-stop/%@.json", stopId];
	NSString * args = [NSString stringWithFormat:@"version=2&minutesAfter=%d",minutesAfter];
	SEL selector = @selector(getArrivalsAndDeparturesForStopV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestStopsForRegion:(MKCoordinateRegion)region withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {
	
	CLLocationCoordinate2D coord = region.center;
	MKCoordinateSpan span = region.span;
	
	NSString * url = @"/api/where/stops-for-location.json";
	NSString * args = [NSString stringWithFormat:@"lat=%f&lon=%f&latSpan=%f&lonSpan=%f&version=2", coord.latitude, coord.longitude, span.latitudeDelta, span.longitudeDelta];
	SEL selector = @selector(getStopsV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestStopsForQuery:(NSString*)stopQuery withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {
	
	CLLocation * location = [self currentOrDefaultLocationToSearch];
	CLLocationCoordinate2D coord = location.coordinate;
	
	stopQuery = [self escapeStringForUrl:stopQuery];
	
	NSString * url = @"/api/where/stops-for-location.json";
	NSString * args = [NSString stringWithFormat:@"lat=%f&lon=%f&query=%@&version=2", coord.latitude, coord.longitude,stopQuery];
	SEL selector = @selector(getStopsV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];	
}

- (id<OBAModelServiceRequest>) requestStopsForRoute:(NSString*)routeId withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {
	NSString * url = [NSString stringWithFormat:@"/api/where/stops-for-route/%@.json", routeId];
	NSString * args = @"version=2";
	SEL selector = @selector(getStopsForRouteV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestStopsForPlacemark:(OBAPlacemark*)placemark withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {

	// request search
	CLLocationCoordinate2D location = placemark.coordinate;
    
	MKCoordinateRegion region = [OBASphericalGeometryLibrary createRegionWithCenter:location latRadius:kSearchRadius lonRadius:kSearchRadius];
	return [self requestStopsForRegion:region withDelegate:delegate withContext:context];
}

- (id<OBAModelServiceRequest>) requestRoutesForQuery:(NSString*)routeQuery withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {

	CLLocation * location = [self currentOrDefaultLocationToSearch];
	CLLocationCoordinate2D coord = location.coordinate;
	
	routeQuery = [self escapeStringForUrl:routeQuery];
	
	NSString * url = @"/api/where/routes-for-location.json";
	NSString * args = [NSString stringWithFormat:@"lat=%f&lon=%f&query=%@&version=2", coord.latitude, coord.longitude,routeQuery];
	SEL selector = @selector(getRoutesV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) placemarksForAddress:(NSString*)address withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {

	// handle search
	CLLocation * location = [self currentOrDefaultLocationToSearch];
	CLLocationCoordinate2D coord = location.coordinate;
    
	address = [self escapeStringForUrl:address];
	
	NSString * url = @"/maps/geo";
	NSString * args = [NSString stringWithFormat:@"ll=%f,%f&spn=0.5,0.5&q=%@", coord.latitude, coord.longitude, address];
	SEL selector = @selector(getPlacemarksFromJSONObject:error:);
	
	return [self request:_googleMapsJsonDataSource url:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestAgenciesWithCoverageWithDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {
	
    // update search filter description
    // self.searchFilterString = [NSString stringWithFormat:@"Transit Agencies"];
	
	NSString * url = @"/api/where/agencies-with-coverage.json";
	NSString * args = @"version=2";
	SEL selector = @selector(getAgenciesWithCoverageV2FromJson:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];
}

- (id<OBAModelServiceRequest>) requestTripDetailsForId:(NSString*)tripId withDelegate:(id<OBAModelServiceDelegate>)delegate withContext:(id)context {
	NSString * url = [NSString stringWithFormat:@"/api/where/trip-details/%@.json", tripId];
	NSString * args = @"version=2";
	SEL selector = @selector(getTripDetailsV2FromJSON:error:);
	
	return [self request:url args:args selector:selector delegate:delegate context:context];	
}

@end


@implementation OBAModelService (Private)


- (OBAModelServiceRequest*) request:(NSString*)url args:(NSString*)args selector:(SEL)selector delegate:(id<OBAModelServiceDelegate>)delegate context:(id)context {
	return [self request:_obaJsonDataSource url:url args:args selector:selector delegate:delegate context:context];
}

- (OBAModelServiceRequest*) request:(OBAJsonDataSource*)source url:(NSString*)url args:(NSString*)args selector:(SEL)selector delegate:(id<OBAModelServiceDelegate>)delegate context:(id)context {

	OBAModelServiceRequest * request = [[[OBAModelServiceRequest alloc] init] autorelease];
	request.delegate = delegate;
	request.context = context;
	request.modelFactory = _modelFactory;
	request.modelFactorySelector = selector;
	
	if( source != _obaJsonDataSource )
		request.checkCode = FALSE;
	
	// if we support background task completion (iOS >= 4.0), allow our requests to complete
	// even if the user switches the foreground application.
	if ([[UIDevice currentDevice] isMultitaskingSupportedSafe]) {
		UIApplication* app = [UIApplication sharedApplication];
		request.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
			[request endBackgroundTask];
		}];
	}
	
	request.connection = [source requestWithPath:url withArgs:args withDelegate:request context:nil];
	
	return request;
}

- (CLLocation*) currentOrDefaultLocationToSearch {
	
	CLLocation * location = _locationManager.currentLocation;
	
	if( ! location )
		location = _modelDao.mostRecentLocation;
	
	if( ! location )
		location = [[[CLLocation alloc] initWithLatitude:47.61229680032385  longitude:-122.3386001586914] autorelease];
	
	return location;
}

- (NSString*) escapeStringForUrl:(NSString*)url {
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSMutableString *escaped = [NSMutableString stringWithString:url];
	NSRange wholeString = NSMakeRange(0, [escaped length]);
	[escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:wholeString];
	[escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:wholeString];
	return escaped;
}

@end