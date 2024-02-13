#import <Foundation/Foundation.h>
#import "AEFCUBBaseListController.h"
#import "UIView+Rounding.h"
#import "UIColor+RGBHex.h"
#import <notify.h>

@implementation AEFCUBBaseListController

#if TARGET_OS_SIMULATOR
// This is needed so it matches what stupid apple changed in iOS 15+
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}
#endif

- (NSArray *)specifiers {
    if (!_specifiers) {
        if ([self isDarkModeEnabled]) {
            _specifiers = [self loadSpecifiersFromPlistName:[self getDarkModePlist] target:self]; 	 // Dark mode
            //self.themeTintColor = [UIColor colorWithRed:193/255.f green:43/255.f blue:252/255.f alpha:1.0f];
            //self.themeTintColor = [UIColor colorFromHexString:@"#19c246"];
            self.themeTintColor = self.view.tintColor;
        } else {
            _specifiers = [self loadSpecifiersFromPlistName:[self getLightModePlist] target:self];   // Light mode
            //self.themeTintColor = [UIColor colorWithRed:193/255.f green:43/255.f blue:252/255.f alpha:1.0f];
            //self.themeTintColor = [UIColor colorFromHexString:@"#19c246"];
            self.themeTintColor = self.view.tintColor;
        }

        self.preferenceBundle = [NSBundle bundleForClass:self.class];

        [self collectSpecifiersWithDependenciesFromArray:_specifiers];

        for (NSInteger i = 0; i <= _specifiers.count - 1; i++) {
            PSSpecifier *specifier = (PSSpecifier *)_specifiers[i];
            [specifier setProperty:self.themeTintColor forKey:PSTintColorKey];

            if (!AEFCUB_DEBUG) {
                NSNumber *developmentOnly = [specifier propertyForKey:@"developmentOnly"];
                
                if ([developmentOnly boolValue] == TRUE) {
                    [_specifiers removeObjectAtIndex:i];
                    i--;
                }
            }
        }
    }

    [self doTinting];

	return _specifiers;
}

// This is needed to update the specifiers to match the new light/dark mode appearance since it just changed
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self isDarkModeEnabled])
        _specifiers = [self loadSpecifiersFromPlistName:[self getDarkModePlist] target:self];   // Dark mode
    else
        _specifiers = [self loadSpecifiersFromPlistName:[self getLightModePlist] target:self];  // Light mode

    [self collectSpecifiersWithDependenciesFromArray:_specifiers];

    for (NSInteger i = 0; i <= _specifiers.count - 1; i++) {
        PSSpecifier *specifier = (PSSpecifier *)_specifiers[i];
        [specifier setProperty:self.themeTintColor forKey:PSTintColorKey];

        if (!AEFCUB_DEBUG) {
            NSNumber *developmentOnly = [specifier propertyForKey:@"developmentOnly"];
            
            if ([developmentOnly boolValue] == TRUE) {
                [_specifiers removeObjectAtIndex:i];
                i--;
            }
        }
    }

    [self reloadTable];
}

- (BOOL)isDarkModeEnabled {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0 && self.traitCollection.userInterfaceStyle == 2)
        return TRUE;
    else
        return FALSE;
}

- (void)setDarkModePlist:(NSString *)darkModePlist lightModePlist:(NSString *)lightModePlist {
    self.darkModePlist = darkModePlist;
    self.lightModePlist = lightModePlist;
}

- (NSString *)getDarkModePlist {
    if (self.darkModePlist != nil)
        return self.darkModePlist;
    else
        return @"Root-Dark";
}

- (NSString *)getLightModePlist {
    if (self.lightModePlist != nil)
        return self.lightModePlist;
    else
        return @"Root-Light";
}

- (void)collectSpecifiersWithDependenciesFromArray:(NSArray *)array {
    //NSLog(@"[CMN_DEBUG] collectSpecifiersWithDependenciesFromArray: %@", array);
    if (!self.specifiersWithDependencies)
        self.specifiersWithDependencies = [NSMutableDictionary new];
    else
        [self.specifiersWithDependencies removeAllObjects];

    for (PSSpecifier *specifier in array) {
        //NSLog(@"[CMN_DEBUG] specifier: %@", specifier);
        NSString *dependsSpecifierRule = [specifier propertyForKey:PSDependsKey];

        if (dependsSpecifierRule.length > 0) {
            NSArray *rules = [dependsSpecifierRule componentsSeparatedByString:@", "];
            //NSLog(@"[CMN_DEBUG] rules: %@", rules);
            for (int i = 0; i < rules.count; i++) {
                NSArray *ruleComponents = [rules[i] componentsSeparatedByString:@" "];
                //NSLog(@"[CMN_DEBUG] ruleComponents: %@", ruleComponents);

                if (ruleComponents.count == 3) {
                    NSString *opposingSpecifierKey = [ruleComponents objectAtIndex:0];
                    if ([self.specifiersWithDependencies objectForKey:opposingSpecifierKey] != nil) {
                        // Get current array
                        NSMutableArray *curSpecifiers = [[self.specifiersWithDependencies objectForKey:opposingSpecifierKey] mutableCopy];
                        [curSpecifiers addObject:specifier];
                        [self.specifiersWithDependencies setObject:curSpecifiers forKey:opposingSpecifierKey];
                    } else {
                        // Just create new array because it doesn't exist already
                        NSArray *newSpecifiers = [NSArray arrayWithObjects:specifier, nil];
                        //[self.specifiersWithDependencies setObject:specifier forKey:opposingSpecifierKey];
                        [self.specifiersWithDependencies setObject:newSpecifiers forKey:opposingSpecifierKey];
                    }
                } else {
                    [NSException raise:NSInternalInconsistencyException format:@"depends key requires three components (Specifier Key, Comparator, Value To Compare To). You have %ld of 3 (%@) for specifier '%@'.", ruleComponents.count, dependsSpecifierRule, [specifier propertyForKey:PSTitleKey]];
                }
            }
        }
    }

    self.hasSpecifiersWithDependencies = (self.specifiersWithDependencies.count > 0);
}

- (void)reloadSpecifiers {
    //NSLog(@"[CMN_DEBUG] reloadSpecifiers");
    [super reloadSpecifiers];

    [self collectSpecifiersWithDependenciesFromArray:self.specifiers];
}

- (void)reloadTable {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
            //self.isReloading = FALSE;
            //[self reload];
            //[self.table reloadSections:indexes withRowAnimation:UITableViewRowAnimationNone];
            //[self.table reconfigureRowsAtIndexPaths:@[indexPath]];
            //[self.table reloadSections:sectionsIndexSet withRowAnimation:UITableViewRowAnimationNone];
            //if (cell != nil) {
                //[self.table _reconfigureCell:cell forRowAtIndexPath:indexPath];
            //}

            //[self.table reloadData];
            //[self.table beginUpdates];
            //[self.table endUpdates];
        });

        /*
        for (int section = 0; section < [self.table numberOfSections]; section++) {
            NSLog(@"[CMN_DEBUG] reloadTable 1");
            int numHiddenRows = 0;
            NSIndexPath *showingIndexPath;

            for (int i = 0; i < [self.table.dataSource tableView:self.table numberOfRowsInSection:section]; i++) {
                NSLog(@"[CMN_DEBUG] reloadTable 2");
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
                PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
                NSLog(@"[CMN_DEBUG] specifier: %@", specifier);
                if (specifier) {
                    BOOL shouldHide = [self shouldHideSpecifier:specifier];
                    if (shouldHide)
                        numHiddenRows++;
                    else
                        showingIndexPath = indexPath;
                }
            }

            NSLog(@"[CMN_DEBUG] numHiddentRows: %i, section: %i", numHiddenRows, section);

            if ((numHiddenRows != 0) && (numHiddenRows == ([self.table.dataSource tableView:self.table numberOfRowsInSection:section] - 1))) {
                NSLog(@"[CMN_DEBUG] reloadTable 3");
                PSSpecifier *specifier = [self specifierAtIndexPath:showingIndexPath];
                if (specifier) {
                    UITableViewCell *specifierCell = [specifier propertyForKey:@"cellObject"];
                    if (specifierCell) {
                        specifierCell.contentView.layer.cornerRadius = 10;
                        specifierCell.contentView.layer.masksToBounds = TRUE;
                        specifierCell.contentView.backgroundColor = [UIColor purpleColor];

                        specifierCell.layer.cornerRadius = 10;
                        specifierCell.layer.masksToBounds = TRUE;
                        specifierCell.backgroundColor = [UIColor greenColor];

                        specifierCell.backgroundView = nil;
                        specifierCell.backgroundView.layer.cornerRadius = 10;
                        specifierCell.backgroundView.layer.masksToBounds = TRUE;
                        specifierCell.backgroundView.backgroundColor = [UIColor orangeColor];

                        specifierCell.selectedBackgroundView.layer.cornerRadius = 10;
                        specifierCell.selectedBackgroundView.layer.masksToBounds = TRUE;
                        specifierCell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];

                        specifierCell.multipleSelectionBackgroundView.layer.cornerRadius = 10;
                        specifierCell.multipleSelectionBackgroundView.layer.masksToBounds = TRUE;
                        specifierCell.multipleSelectionBackgroundView.backgroundColor = [UIColor redColor];
                        
                        //UIView *cellView = (UIView *)specifierCell;
                        //[(UIView *)specifierCell roundCorners:UIViewCornersBottomLeft];
                        [specifierCell roundCorners:UIViewCornersBottomLeft radius:15];
                    }
                }
            }
        }
        */
    });
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.layer.cornerRadius = 10;
    //cell.layer.masksToBounds = TRUE;
    //cell.backgroundColor = [UIColor greenColor];
    //[cell roundCorners:UIViewCornersAll radius:10];
    //[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];

    if (self.hasSpecifiersWithDependencies) {
        int numHiddenRows = 0;
        NSIndexPath *showingIndexPath;

        for (int i = 0; i < [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section]; i++) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            PSSpecifier *specifier = [self specifierAtIndexPath:newIndexPath];
            NSLog(@"[CMN_DEBUG] specifier: %@", specifier);
            if (specifier) {
                BOOL shouldHide = [self shouldHideSpecifier:specifier];
                if (shouldHide)
                    numHiddenRows++;
                else
                    showingIndexPath = newIndexPath;
            }
        }

        if ((numHiddenRows != 0) && (numHiddenRows == ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] - 1))) {
            if (showingIndexPath == indexPath) {
                [cell roundCorners:UIViewCornersAll radius:10];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (self.hasSpecifiersWithDependencies) {
        int numHiddenRows = 0;
        NSIndexPath *showingIndexPath;

        for (int i = 0; i < [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section]; i++) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            PSSpecifier *specifier = [self specifierAtIndexPath:newIndexPath];
            NSLog(@"[CMN_DEBUG] specifier: %@", specifier);
            if (specifier) {
                BOOL shouldHide = [self shouldHideSpecifier:specifier];
                if (shouldHide)
                    numHiddenRows++;
                else
                    showingIndexPath = newIndexPath;
            }
        }

        if ((numHiddenRows != 0) && (numHiddenRows == ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] - 1))) {
            if (showingIndexPath == indexPath) {
                [cell roundCorners:UIViewCornersAll radius:10];
            }
        }
    }

    return cell;
}
*/

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    //NSLog(@"[CMN_DEBUG] setPreferenceValue: %@ specifier:%@", value, specifier);
    [super setPreferenceValue:value specifier:specifier];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //dispatch_async(dispatch_get_main_queue(), ^{
            //[self.table reloadData];
        //});
        
        if (self.hasSpecifiersWithDependencies) {
            for (id key in self.specifiersWithDependencies) {
                //NSLog(@"[CMN_DEBUG] key: %@", key);
                if ([key isEqualToString:[specifier propertyForKey:@"key"]]) {
                    //NSLog(@"[CMN_DEBUG] self.table: %@", self.table);
                    //NSLog(@"[CMN_DEBUG] self.table.hasUncommittedUpdates: %i", self.table.hasUncommittedUpdates);
                    //[self.table reloadData];

                    //NSIndexPath *indexPath = [self indexPathForSpecifier:specifier];
                    //NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:indexPath.section];

                    //NSArray *indexPaths = [[NSArray *] alloc] initWith

                    //NSIndexSet *sectionsIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [self.table numberOfSections] - 1)];

                    //UITableViewCell *cell = [specifier propertyForKey:@"cellObject"];

                    //NSLog(@"[CMN_DEBUG] self.isReloading: %i", self.isReloading);

                    [self reloadTable];

                    /*
                    //if (!self.isReloading) {
                        //self.isReloading = TRUE;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.table reloadData];
                            //self.isReloading = FALSE;
                            //[self reload];
                            //[self.table reloadSections:indexes withRowAnimation:UITableViewRowAnimationNone];
                            //[self.table reconfigureRowsAtIndexPaths:@[indexPath]];
                            //[self.table reloadSections:sectionsIndexSet withRowAnimation:UITableViewRowAnimationNone];
                            //if (cell != nil) {
                                //[self.table _reconfigureCell:cell forRowAtIndexPath:indexPath];
                            //}

                            //[self.table reloadData];
                            //[self.table beginUpdates];
                            //[self.table endUpdates];
                        });
                    //}
                    */
                }
            }
        }
    });
}

/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    //view.tintColor = [UIColor blackColor];

    // Text Color
    //UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //[header.textLabel setTextColor:[UIColor redColor]];

    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}
*/

- (NSInteger)numberOfHiddenSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"[CMN_DEBUG] numberOfHiddenSectionsInTableView: %@", tableView);
    NSInteger numHiddenSections = 0;

    for (int section = 0; section < [tableView numberOfSections]; section++) {
        int numHiddenRows = 0;

        for (int i = 0; i < [tableView.dataSource tableView:tableView numberOfRowsInSection:section]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
            if (specifier) {
                BOOL shouldHide = [self shouldHideSpecifier:specifier];
                if (shouldHide)
                    numHiddenRows++;
            }
        }

        if ((numHiddenRows != 0) && (numHiddenRows == [tableView.dataSource tableView:tableView numberOfRowsInSection:section]))
            numHiddenSections++;
    }

    return numHiddenSections;
}

- (BOOL)tableView:(UITableView *)tableView shouldHideSection:(NSInteger)section {
    //NSLog(@"[CMN_DEBUG] tableView: %@ shouldHideSection: %li", tableView, section);
    //NSLog(@"[CMN_DEBUG] shouldHideSection: %li", section);
    int numHiddenRows = 0;

    for (int i = 0; i < [tableView.dataSource tableView:tableView numberOfRowsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
        if (specifier) {
            BOOL shouldHide = [self shouldHideSpecifier:specifier];
            if (shouldHide)
                numHiddenRows++;
        }
    }

    if ((numHiddenRows != 0) && (numHiddenRows == [tableView.dataSource tableView:tableView numberOfRowsInSection:section]))
        return TRUE;
    else
        return FALSE;
}

- (NSInteger)numberOfHiddenHeadersInTableView:(UITableView *)tableView {
    //NSLog(@"[CMN_DEBUG] numberOfHiddenHeadersInTableView: %@", tableView);
    NSInteger numHiddenHeaders = 0;

    for (int section = 0; section < [tableView numberOfSections]; section++) {
        if ([self tableView:tableView shouldHideSection:section]) {
            UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
            if (headerView != nil)
                numHiddenHeaders++;
        }
    }

    return numHiddenHeaders;
}

- (NSInteger)numberOfHiddenFootersInTableView:(UITableView *)tableView {
    //NSLog(@"[CMN_DEBUG] numberOfHiddenFootersInTableView: %@", tableView);
    NSInteger numHiddenFooters = 0;

    for (int section = 0; section < [tableView numberOfSections]; section++) {
        if ([self tableView:tableView shouldHideSection:section]) {
            UIView *footerView = [self tableView:tableView viewForFooterInSection:section];
            if (footerView != nil)
                numHiddenFooters++;
        }
    }

    return numHiddenFooters;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSpecifiersWithDependencies) {
        PSSpecifier *dynamicSpecifier = [self specifierAtIndexPath:indexPath];
        if (dynamicSpecifier) {
            for (id key in self.specifiersWithDependencies) {
                NSArray *specifiers = [self.specifiersWithDependencies objectForKey:key];
                if ([specifiers containsObject:dynamicSpecifier]) {
                    BOOL shouldHide = [self shouldHideSpecifier:dynamicSpecifier];

                    UITableViewCell *specifierCell = [dynamicSpecifier propertyForKey:@"cellObject"];
                    if (specifierCell)
                        specifierCell.clipsToBounds = shouldHide;

                    if (shouldHide)
                        return 0;
                }
            }
        }
    }

    // This is needed so we can round all the corners of the cells in groups, after hiding all other cells, otherwise only some corners get rounded
    // We also handle hiding the separator between cells because it is still showing after hiding all other cells in group
    int numHiddenRows = 0;
    NSIndexPath *firstShowingIndexPath;
    NSIndexPath *lastShowingIndexPath;

    for (int i = 0; i < [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section]; i++) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        PSSpecifier *specifier = [self specifierAtIndexPath:newIndexPath];
        if (specifier) {
            // Make any previously hidden separators visible first
            UITableViewCell *specifierCell = [specifier propertyForKey:@"cellObject"];
            if (specifierCell)
                for (id subview in specifierCell.subviews)
                    if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
                        UIView *sperarator = (UIView *)subview;
                        if (sperarator.hidden == TRUE)
                            sperarator.hidden = FALSE;
                    }

            BOOL shouldHide = [self shouldHideSpecifier:specifier];
            if (shouldHide) {
                numHiddenRows++;
            } else {
                lastShowingIndexPath = newIndexPath;
                if (!firstShowingIndexPath)
                    firstShowingIndexPath = newIndexPath;
            }
        }
    }

    if ((numHiddenRows != 0) && (numHiddenRows != ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section]))) {
        // Verify that there is in fact a row that is hidden in this section before we take any further actions
        if ((numHiddenRows != 0) && (numHiddenRows == ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] - 1))) {
            // If there is only one row hidden in this section
            if (lastShowingIndexPath == indexPath) {
                PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
                if (specifier) {
                    UITableViewCell *specifierCell = [specifier propertyForKey:@"cellObject"];
                    if (specifierCell) {
                        //NSLog(@"[CMN_DEBUG] Rounding corners of: %@", specifierCell);
                        [specifierCell roundCorners:UIViewCornersAll radius:10];
                        for (id subview in specifierCell.subviews)
                            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) { // Check if subview is a separator
                                UIView *sperarator = (UIView *)subview;
                                sperarator.hidden = TRUE;
                            }
                    }
                }
            }
        } else {
            // If there is still more than one row showing in this section
            if (firstShowingIndexPath == indexPath) {
                // If the indexPath of the current row matches the indexPath of the first row (AKA the current is the first row)
                PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
                if (specifier) {
                    UITableViewCell *specifierCell = [specifier propertyForKey:@"cellObject"];
                    if (specifierCell) {                        
                        if (firstShowingIndexPath == lastShowingIndexPath) {
                            // If first showing is also last showing
                            [specifierCell roundCorners:UIViewCornersAll radius:10];
                        } else {
                            [specifierCell roundCorners:UIViewCornersTop radius:10];
                        }

                        for (id subview in specifierCell.subviews)
                            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) { // Check if subview is a separator
                                UIView *sperarator = (UIView *)subview;
                                sperarator.hidden = TRUE;
                            }
                    }
                }
            } else if (lastShowingIndexPath == indexPath) {
                // If the indexPath of the current row matches the indexPath of the last row (AKA the current is the last row)
                PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
                if (specifier) {
                    UITableViewCell *specifierCell = [specifier propertyForKey:@"cellObject"];
                    if (specifierCell) {                        
                        if (firstShowingIndexPath == lastShowingIndexPath) {
                            // If first showing is also last showing
                            [specifierCell roundCorners:UIViewCornersAll radius:10];
                        } else {
                            [specifierCell roundCorners:UIViewCornersBottom radius:10];
                        }

                        for (id subview in specifierCell.subviews)
                            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) { // Check if subview is a separator
                                UIView *sperarator = (UIView *)subview;
                                sperarator.hidden = TRUE;
                            }
                    }
                }
            }
        }
    }

    //return UITableViewAutomaticDimension;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //NSLog(@"[CMN_DEBUG] tableView: %@ viewForFooterInSection: %li", tableView, section);
    //NSLog(@"[CMN_DEBUG] viewForFooterInSection: %li", section);
    //NSLog(@"[CMN_DEBUG] tableView: %@", tableView);
    //NSLog(@"[CMN_DEBUG] section: %ld", section);

    if ([self tableView:tableView shouldHideSection:section]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        return view;
    } else {
        return [super tableView:tableView viewForFooterInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //NSLog(@"[CMN_DEBUG] tableView: %@ heightForFooterInSection: %li", tableView, section);
    //NSLog(@"[CMN_DEBUG] heightForFooterInSection: %li", section);
    //NSLog(@"[CMN_DEBUG] tableView: %@", tableView);
    //NSLog(@"[CMN_DEBUG] tableView.dataSource: %@", tableView.dataSource);
    //NSLog(@"[CMN_DEBUG] section: %ld", section);
    //NSLog(@"[CMN_DEBUG] tableView.bounds: %@", NSStringFromCGRect(tableView.bounds));

    if ([self tableView:tableView shouldHideSection:section]) {
        if ([self numberOfHiddenSectionsInTableView:tableView] == 0) {
            return 7.5f;
        }
        return 7.5f / [self numberOfHiddenSectionsInTableView:tableView];
    } else {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //NSLog(@"[CMN_DEBUG] tableView: %@ viewForHeaderInSection: %li", tableView, section);
    //NSLog(@"[CMN_DEBUG] viewForHeaderInSection: %li", section);
    //NSLog(@"[CMN_DEBUG] tableView: %@", tableView);
    //NSLog(@"[CMN_DEBUG] section: %ld", section);

    if ([self tableView:tableView shouldHideSection:section]) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        return view;
    } else {
        return [super tableView:tableView viewForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //NSLog(@"[CMN_DEBUG] tableView: %@ heightForHeaderInSection: %li", tableView, section);
    //NSLog(@"[CMN_DEBUG] heightForHeaderInSection: %li", section);
    //NSLog(@"[CMN_DEBUG] tableView: %@", tableView);
    //NSLog(@"[CMN_DEBUG] tableView.dataSource: %@", tableView.dataSource);
    //NSLog(@"[CMN_DEBUG] section: %ld", section);
    //NSLog(@"[CMN_DEBUG] tableView.bounds: %@", NSStringFromCGRect(tableView.bounds));

    if ([self tableView:tableView shouldHideSection:section]) {
        return 0.01f;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (BOOL)shouldHideSpecifier:(PSSpecifier *)specifier {
    //NSLog(@"[CMN_DEBUG] shouldHideSpecifier: %@", specifier);
    BOOL shouldHide = FALSE;
    
    if (specifier) {
        NSString *dependsSpecifierRule = [specifier propertyForKey:PSDependsKey];

        NSArray *rules = [dependsSpecifierRule componentsSeparatedByString:@", "];
        //NSLog(@"[CMN_DEBUG] rules: %@", rules);
        for (int i = 0; i < rules.count; i++) {
            NSArray *ruleComponents = [rules[i] componentsSeparatedByString:@" "];

            //PSSpecifier *opposingSpecifier = [self specifierForID:[ruleComponents objectAtIndex:0]];
            PSSpecifier *opposingSpecifier = [self specifierForKey:[ruleComponents objectAtIndex:0]];
            id opposingValue = [self readPreferenceValue:opposingSpecifier];
            id requiredValue = [ruleComponents objectAtIndex:2];

            //NSLog(@"[CMN_DEBUG] rule: %@, opposingSpecifier: %@, opposingValue: %@, requiredValue: %@", dependsSpecifierRule, opposingSpecifier, opposingValue, requiredValue);

            //NSLog(@"[CMN_DEBUG] requiredValue class: %@", NSStringFromClass([requiredValue class]));

            if ([opposingValue isKindOfClass:NSNumber.class]) {
                AEFCUBDependsSpecifierOperatorType operatorType = [self operatorTypeForString:[ruleComponents objectAtIndex:1]];
                //NSLog(@"[CMN_DEBUG] operatorType: %li", operatorType);

                if ([[requiredValue uppercaseString] isEqualToString:@"TRUE"] ||
                    [[requiredValue uppercaseString] isEqualToString:@"FALSE"] ||
                    [[requiredValue uppercaseString] isEqualToString:@"YES"] ||
                    [[requiredValue uppercaseString] isEqualToString:@"NO"]) {

                    //NSLog(@"[CMN_DEBUG] NSString: %@, BOOL: %i", requiredValue, [requiredValue boolValue]);
                    
                    switch (operatorType) {
                        case AEFCUBEqualToOperatorType:
                            if ([opposingValue intValue] != [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBNotEqualToOperatorType:
                            if ([opposingValue intValue] == [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBGreaterThanOperatorType:
                            if ([opposingValue intValue] < [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBLessThanOperatorType:
                            if ([opposingValue intValue] > [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBGreaterThanOrEqualToOperatorType:
                            if ([opposingValue intValue] <= [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBLessThanOrEqualToOperatorType:
                            if ([opposingValue intValue] >= [requiredValue boolValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBBlankOperatorType:
                            shouldHide = FALSE;
                        break;

                        default:
                            shouldHide = FALSE;
                        break;
                    }
                } else {
                    switch (operatorType) {
                        case AEFCUBEqualToOperatorType:
                            //return ([opposingValue intValue] == [requiredValue intValue]);
                            //return ([opposingValue intValue] != [requiredValue intValue]);                            
                            if ([opposingValue intValue] != [requiredValue intValue])
                                shouldHide = TRUE;
                            //return ([opposingValue intValue] != [requiredValue intValue]);
                        break;

                        case AEFCUBNotEqualToOperatorType:
                            //return ([opposingValue intValue] != [requiredValue intValue]);
                            //return ([opposingValue intValue] == [requiredValue intValue]);
                            if ([opposingValue intValue] == [requiredValue intValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBGreaterThanOperatorType:
                            //return ([opposingValue intValue] > [requiredValue intValue]);
                            //return ([opposingValue intValue] < [requiredValue intValue]);
                            if ([opposingValue intValue] < [requiredValue intValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBLessThanOperatorType:
                            //return ([opposingValue intValue] < [requiredValue intValue]);
                            //return ([opposingValue intValue] > [requiredValue intValue]);
                            if ([opposingValue intValue] > [requiredValue intValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBGreaterThanOrEqualToOperatorType:
                            //return ([opposingValue intValue] >= [requiredValue intValue]);
                            //return ([opposingValue intValue] <= [requiredValue intValue]);
                            if ([opposingValue intValue] <= [requiredValue intValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBLessThanOrEqualToOperatorType:
                            //return ([opposingValue intValue] <- [requiredValue intValue]);
                            //return ([opposingValue intValue] >= [requiredValue intValue]);
                            if ([opposingValue intValue] >= [requiredValue intValue])
                                shouldHide = TRUE;
                        break;

                        case AEFCUBBlankOperatorType:
                            shouldHide = FALSE;
                        break;

                        default:
                            shouldHide = FALSE;
                        break;
                    }
                }
            }

            if ([opposingValue isKindOfClass:NSString.class]) {
                //return [opposingValue isEqualToString:requiredValue];
                //return ![opposingValue isEqualToString:requiredValue];
                if (![opposingValue isEqualToString:requiredValue])
                    shouldHide = TRUE;
            }

            if ([opposingValue isKindOfClass:NSArray.class]) {
                //return [opposingValue containsObject:requiredValue];
                //return ![opposingValue containsObject:requiredValue];
                if (![opposingValue containsObject:requiredValue])
                    shouldHide = TRUE;
            }
        }
    }

    return shouldHide;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    //NSLog(@"[CMN_DEBUG] readPreferenceValue: %@", specifier);
    if (specifier == nil || [specifier propertyForKey:@"defaults"] == nil) return nil;
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[specifier propertyForKey:@"defaults"]];

	if ([prefsDict objectForKey:[specifier propertyForKey:@"key"]] != nil)
        return [prefsDict objectForKey:[specifier propertyForKey:@"key"]];
	else
        if ([specifier propertyForKey:@"default"] != nil)
            return [specifier propertyForKey:@"default"];

    return nil;
}

- (PSSpecifier *)specifierForKey:(NSString *)key {
    //NSLog(@"[CMN_DEBUG] specifierForKey: %@", key);
    for (int i = 0; i < _specifiers.count; i++) {
        //NSLog(@"[CMN_DEBUG] target: '%@', current: '%@'", key, [_specifiers[i] propertyForKey:@"key"]);
        if ([key isEqualToString:[_specifiers[i] propertyForKey:@"key"]])
            return _specifiers[i];
    }

    return nil;
}

- (AEFCUBDependsSpecifierOperatorType)operatorTypeForString:(NSString *)string {
    //NSLog(@"[CMN_DEBUG] operatorTypeForString: %@", string);
    NSDictionary *operatorValues = @{
        @"==" : @(AEFCUBEqualToOperatorType),
        @"!=" : @(AEFCUBNotEqualToOperatorType),
        @">"  : @(AEFCUBGreaterThanOperatorType),          // In plist it needs to be &gt; because of stupid xml
        @"<"  : @(AEFCUBLessThanOperatorType),             // In plist it needs to be &lt; because of stupid xml
        @">=" : @(AEFCUBGreaterThanOrEqualToOperatorType), // In plist it needs to be &gt;= because of stupid xml
        @"<=" : @(AEFCUBLessThanOrEqualToOperatorType),    // In plist it needs to be &lt;= because of stupid xml
        @""   : @(AEFCUBBlankOperatorType)
    };
    return [operatorValues[string] intValue];
}

- (void)loadView {
	[super loadView];

	[self doTinting];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self doTinting];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self doTinting];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self doTinting];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	// Revert the tinting when disappearing so it will not continue to stay after exiting our preference pane
	[self reverseTinting];
}

- (void)doTinting {
	self.view.tintColor = self.themeTintColor;
	UINavigationBar *bar = self.navigationController.navigationController.navigationBar;
	bar.tintColor = self.themeTintColor;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.themeTintColor;
	[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = self.themeTintColor;
	[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = self.themeTintColor;
}

- (void)reverseTinting {
	self.view.tintColor = NULL;
	UINavigationBar *bar = self.navigationController.navigationController.navigationBar;
	bar.tintColor = NULL;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = NULL;
	[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = NULL;
	[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = NULL;
}

- (NSString *)localizedStringForKey:(NSString *)key {
	return [self.preferenceBundle localizedStringForKey:key value:@"" table:nil];
}

- (NSString *)pathOfResourceWithName:(NSString *)name type:(NSString *)ext {
    if (self.preferenceBundle == nil) return @"";
    return [self.preferenceBundle pathForResource:name ofType:ext];
}

- (void)reset {
	UIAlertController *confirmResetAlert = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"RESET_TITLE"] message:[self localizedStringForKey:@"RESET_MESSAGE"] preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"RESET"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		notify_post("com.dcproducts.aefcubypass/Reset");
		notify_post("com.dcproducts.aefcubypass/Respring");
    }];

	UIAlertAction *cancel = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:nil];

    [confirmResetAlert addAction:cancel];
	[confirmResetAlert addAction:confirm];

	[self presentViewController:confirmResetAlert animated:YES completion:nil];
}

- (void)respring {
	UIAlertController *confirmRespringAlert = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"RESPRING_TITLE"] message:[self localizedStringForKey:@"RESPRING_MESSAGE"] preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"RESPRING"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		notify_post("com.dcproducts.aefcubypass/Respring");
    }];

	UIAlertAction *cancel = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:nil];

    [confirmRespringAlert addAction:cancel];
	[confirmRespringAlert addAction:confirm];

	[self presentViewController:confirmRespringAlert animated:YES completion:nil];
}

- (void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/dcalabro3"] options:@{} completionHandler:nil];
}

- (void)paypal {
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/DerekCalabro"] options:@{} completionHandler:nil];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.com/donate/?cmd=_donations&business=dtcalabro@gmail.com&item_name=iOS%20Tweak%20Development"] options:@{} completionHandler:nil];
}

- (void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dtcalabro"] options:@{} completionHandler:nil];
}

- (void)discord {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discordapp.com/users/517728575063851014"] options:@{} completionHandler:nil];
}

- (void)bugReport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dtcalabro@gmail.com?subject=%5BiOS%20Tweak%20Support%5D%20Bug%20Report&body=Tweak%20name%3A%20AEFCUBypass%0D%0AMessage%3A%20I%20found%20a%20bug%20while%20using%20the%20AEFCUBypass%20tweak.%20The%20following%20explains%20how%20to%20reproduce%20the%20bug%20and%20includes%20any%20additional%20information%20I%20may%20have%20regarding%20the%20issue.%0D%0A%0D%0A"] options:@{} completionHandler:nil];
}

- (void)featureRequest {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dtcalabro@gmail.com?subject=%5BiOS%20Tweak%20Support%5D%20Feature%20Request&body=Tweak%20name%3A%20AEFCUBypass%0D%0AMessage%3A%20I%20have%20a%20feature%20request%20for%20the%20AEFCUBypass%20tweak.%20The%20following%20explains%20my%20idea%20and%20any%20other%20input%20or%20information%20I%20may%20have%20regarding%20it.%0D%0A%0D%0A"] options:@{} completionHandler:nil];
}

@end
