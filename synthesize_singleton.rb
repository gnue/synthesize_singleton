#!/usr/bin/env ruby

=begin

= Objective-C のシングルトンのひな形を生成する

Authors::   GNUE(鵺)
Version::   1.0.1 2010-12-30 gnue
Copyright:: Copyright (C) gnue, 2010. All rights reserved.
License::   MIT ライセンスに準拠

　Objective-C のシングルトンのひな形を生成する

== 使い方

$ synthesize_singleton.rb ClassName...

== TODO

== 開発履歴

* 1.0.1 2010-12-30
  * 実装のひな形をヒアドキュメントから DATA.read を使うように変更
* 1.0 2010-12-29
  * とりあえず作ってみた

=end


class CocoaSingleton
	def initialize(className)
        @className = capitalize(className)
	end

	def capitalize(str)
		# 先頭文字のみ大文字にして後ろは変更しない
		str.gsub(/^./) { $&.upcase }
	end

	def ganerate(className = @className)
		# ヘッダと実装のひな形をファイルに書き出す
		File.open("#{className}.h", 'w') { |f|
			f.print interface(className)
		}

		File.open("#{className}.m", 'w') { |f|
			f.print implementation(className)
		}
	end

	def interface(className = @className)
		# ヘッダの生成
		<<-"EOS"
#import <Cocoa/Cocoa.h>


@interface #{className} : NSObject {
}

+ (#{className} *)shared#{className};

@end
		EOS
	end

	def implementation(className = @className)
		# 実装の生成
		DATA.read.gsub(/FooBar/, className)
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


__END__

#import "FooBar.h"


static FooBar *sharedFooBar = nil;


@implementation FooBar

#pragma mark -
#pragma mark シングルトン

+ (FooBar *)sharedFooBar
{
    @synchronized(self) {
        if (sharedFooBar  == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return sharedFooBar;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedFooBar == nil) {
            sharedFooBar = [super allocWithZone:zone];
            return sharedFooBar;  // 最初の割り当てで代入し、返す
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
