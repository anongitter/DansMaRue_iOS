//
//  UpdateCell.m
//  InfoVoirie
//
//  Created by Christophe Boivin on 13/07/10.
//  Copyright 2010 C4MProd. All rights reserved.
//

#import "UpdateCell.h"
//#import "imageLoader.h"
#import "ImageManager.h"

@implementation UpdateCell

@synthesize mLabelDescription;
@synthesize mLabelDate;
@synthesize mImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

-(void) updateWithInfo:(NSDictionary*)_info
{
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	mLabelDescription.text = [_info objectForKey:@"commentary"];
	if ([mLabelDescription.text length] == 0) {
		mLabelDescription.text = @"Photo de près ajoutée";
	}
	
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:kDateFormat];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE dd MMMM\nHH:mm"];
	[dateFormatter setLocale:locale];
	
	NSString* modifyDate = [_info objectForKey:@"date"];
	modifyDate = [[modifyDate componentsSeparatedByString:@"."] objectAtIndex:0];
	NSDate *date = [inputFormatter dateFromString:modifyDate];
	
	NSString* formattedDate = [dateFormatter stringFromDate:date];
	mLabelDate.text = formattedDate;
	
	//mIndex = _index;
	
	
	/*ImageLoader *imageLoader = [ImageLoader sharedImageLoader];
	UIImage *image = [imageLoader loadImage:[_info objectForKey:@"photo_url"] forDelegate:self];*/
	mImageURL = [[_info objectForKey:@"photo_url"] retain];
	
	[[ImageManager sharedImageManager] getImageNamed:mImageURL withDelegate:mImageView];
	
	//[mImageView setImage:image];
	[inputFormatter release];
	[dateFormatter release];
	[locale release];
}

/*-(void) didLoadImage:(UIImage*) _Image
{
	[self.mImageView setImage:_Image];
	
	[self setNeedsDisplay];
}*/
	 
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
	mImageView.image = nil;
	
	if (mImageURL != nil)
	{
		[[ImageManager sharedImageManager] removeDelegateForImage:mImageURL];
	}
	
	[mImageURL release];
	mImageURL = nil;
}

- (void)dealloc {
	[mLabelDate release];
	[mLabelDescription release];
	[mImageView release];
	[mImageURL release];
	//[[ImageLoader sharedImageLoader] cancelActions];
	
    [super dealloc];
}


@end
