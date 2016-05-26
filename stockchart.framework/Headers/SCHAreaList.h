#import <Foundation/Foundation.h>


@class SCHArea;


typedef NSMutableArray SCHAreaList;


BOOL schAreaListRemoveAreaByName(SCHAreaList *list, NSString *name);

SCHArea *schAreaListFindAreaByName(SCHAreaList *list, NSString *name);