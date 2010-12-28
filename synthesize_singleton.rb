#!/usr/bin/env ruby

=begin

= Objective-C のシングルトンのひな形を生成する

Authors::   GNUE(鵺)
Version::   1.0 2010-12-29 gnue
Copyright:: Copyright (C) gnue, 2010. All rights reserved.
License::   MIT ライセンスに準拠

　Objective-C のシングルトンのひな形を生成する

== 使い方

$ synthesize_singleton.rb ClassName...

== TODO

== 開発履歴

* 1.0 2010-12-29
  * とりあえず作ってみた

=end


class CocoaSingleton
	def initialize(className)
        @className = className
	end

	def ganerate(className = @className)
		File.open("#{className}.h", 'w') { |f|
			f.print ganerate_interface(className)
		}

		File.open("#{className}.m", 'w') { |f|
			f.print ganerate_implementation(className)
		}
	end

	def ganerate_interface(className = @className)
		# ヘッダの生成
		<<EOS
#import <Cocoa/Cocoa.h>


@interface #{className} : NSObject {
}

+ (#{className}*)shared#{className};

@end
EOS
	end

	def ganerate_implementation(className = @className)
		# 実装の生成
		<<EOS
#import "#{className}.h"


static #{className} *shared#{className} = nil;


@implementation #{className}

#pragma mark -
#pragma mark シングルトン

+ (#{className}*)shared#{className}
{
    @synchronized(self) {
        if (shared#{className}  == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return shared#{className};
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (shared#{className} == nil) {
            shared#{className} = [super allocWithZone:zone];
            return shared#{className};  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
    // 何もしない
}

- (id)autorelease
{
    return self;
}

@end
EOS
	end
end


if ARGV.length == 0
	cmd = File.basename $0
	print "Usage: #{cmd} ClassName...\n"
	exit
end

ARGV.each { |className|
	singleton = CocoaSingleton.new(className)
	singleton.ganerate
}
