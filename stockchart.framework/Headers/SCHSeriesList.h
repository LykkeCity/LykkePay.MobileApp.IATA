#import <Foundation/Foundation.h>


@class SCHSeries;


typedef NSMutableArray SCHSeriesList;


BOOL schSeriesListRemoveSeriesByName(SCHSeriesList *list, NSString *name);

SCHSeries *schSeriesListFindSeriesByName(SCHSeriesList *list, NSString *name);