LDFLAGS = -F /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks
LDLIBS = -framework Foundation -framework IOKit -framework CoreFoundation -framework BezelServices

all:
	clang -o lmutracker lmutracker.mm $(LDFLAGS) $(LDLIBS)
