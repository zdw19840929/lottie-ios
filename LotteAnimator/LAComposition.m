//
//  LAScene.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAComposition.h"
#import "LALayer.h"

@implementation LAComposition {
  NSDictionary *_modelMap;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  NSNumber *width = jsonDictionary[@"w"];
  NSNumber *height = jsonDictionary[@"h"];
  if (width && height) {
    CGRect bounds = CGRectMake(0, 0, width.floatValue, height.floatValue);
    _compBounds = bounds;
  }
  
  _startFrame = [jsonDictionary[@"ip"] copy];
  _endFrame = [jsonDictionary[@"op"] copy];
  _framerate = [jsonDictionary[@"fr"] copy];
  
  if (_startFrame && _endFrame && _framerate) {
    NSInteger frameDuration = _endFrame.integerValue - _startFrame.integerValue;
    NSTimeInterval timeDuration = frameDuration / _framerate.floatValue;
    _timeDuration = timeDuration;
  }
  
  NSArray *layersJSON = jsonDictionary[@"layers"];
  NSMutableArray *layers = [NSMutableArray array];
  NSMutableDictionary *modelMap = [NSMutableDictionary dictionary];
  
  NSMutableDictionary *parentToChildrenMap = [NSMutableDictionary dictionary];
  
  for (NSDictionary *layerJSON in layersJSON) {
    LALayer *layer = [[LALayer alloc] initWithJSON:layerJSON frameRate:_framerate];
    [layers addObject:layer];
    modelMap[layer.layerID] = layer;
    
    if (layer.parentID) {
      NSMutableArray *children = parentToChildrenMap[layer.parentID];
      if (!children) {
        children = [NSMutableArray array];
        parentToChildrenMap[layer.parentID] = children;
      }
      [children addObject:[layer.layerID copy]];
    }
  }
  
  for (NSNumber *parent in parentToChildrenMap.allKeys) {
    NSArray *children = parentToChildrenMap[parent];
    LALayer *parentLayer = modelMap[parent];
    parentLayer.childrenIDs = children;
  }
  
  _modelMap = modelMap;
  _layers = layers;
}

- (LALayer *)layerModelForID:(NSNumber *)layerID {
  return _modelMap[layerID];
}

@end
