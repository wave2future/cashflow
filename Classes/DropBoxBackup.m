#define	BACKUP_FILENAME	@"cashflow.db"

@implementation DropBoxBackup

- (void)dealloc
{
    [mRestClient release];
    [super dealloc];
}

- (void)doBackup:(UIViewController *)viewController
{
    mMode = MODE_BACKUP;
    mViewController = viewController;
    [self _login];
}

- (void)doRestore:(UIViewController *)viewController
{
    mMode = MODE_RESTORE;
    mViewController = viewController;
    [self _login];
}

- (void)_login
{
    DBSession *session = [DBSession sharedSession];
    
    // ログイン処理
    if (![session isLinked]) {
	// 未ログイン
	DBLoginController *controller = [[DBLoginController new] autorelease];
	controller.delegate = self;
	[controller presentFromController:viewController];
    } else {
	// ログイン済み
	[self _exec];
    }
}

- (void)_exec
{
    NSString *dbPath = [[Database instance] dbPath:DBNAME];

    switch (mMode) {
    case MODE_BACKUP:
	[self.restClient
	    uploadFile:filename
	    toPath:@"/"
	    fromPath:dbPath];
	break;

    case MODE_RESTORE:
	[self.restClient
	    loadFile:[NSString stringWithFormat:@"/%@", BACKUP_FOLDER, BACKUP_FILENAME]
	    intoPath:dbPath];
	break;
    }
}

- (DBRestClient *)restClient
{
    if (mRestClient == nil) {
    	mRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	mRestClient.delegate = self;
    }
    return restClient;
}

#pragma mrk DBRestClientDelegate

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
}

// restore done
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
}

// restore failed
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    [self _doBackup];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
    // callback?
}

@end
