//
//  Config.h
//  OpenNote
//
//  Created by Zin ZH on 12-12-3.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#ifndef OpenNote_Config_h
#define OpenNote_Config_h

// usually you don't need to modify these.
#define httpEncoding                    @"gzip"
#define userAgent                       nil

#define OpenNoteSDKVersion              @"1.0"
#define OpenNoteOAuthVersion            @"1.0"
#define OpenNoteOauthSignatureMethod    @"HMAC-SHA1"
#define OpenNoteBaseURL                 @"http://note.youdao.com"
#define OpenNoteRequestTokenPath        @"/oauth/request_token"
#define OpenNoteAuthorizePath           @"/oauth/authorize"
#define OpenNoteAccessTokenPath         @"/oauth/access_token"

// 用户API
#define OpenNoteAPIUserGet              @"/yws/open/user/get.json" // GET
// 笔记本API
#define OpenNoteAPINotebookAll          @"/yws/open/notebook/all.json" // POST application/x-www-form-urlencoded
#define OpenNoteAPINotebookList         @"/yws/open/notebook/list.json" // POST application/x-www-form-urlencoded notebook[YES]
#define OpenNoteAPINotebookCreate       @"/yws/open/notebook/create.json" // POST application/x-www-form-urlencoded name[YES]
#define OpenNoteAPINotebookDelete       @"/yws/open/notebook/delete.json" // POST application/x-www-form-urlencoded notebook[YES]
// 笔记API
#define OpenNoteAPINoteCreate           @"/yws/open/note/create.json" // POST multipart/form-data source,author,title,content[YES],notebook
#define OpenNoteAPINoteGet              @"/yws/open/note/get.json" // POST application/x-www-form-urlencoded path[YES]
#define OpenNoteAPINoteUpdate           @"/yws/open/note/update.json" // POST multipart/form-data path[YES],source,author,title,content[YES]
#define OpenNoteAPINoteMove             @"/yws/open/note/move.json" // POST application/x-www-form-urlencoded path[YES],notebook[YES]
#define OpenNoteAPINoteDelete           @"/yws/open/note/delete.json" // POST application/x-www-form-urlencoded path[YES]
// 附件API
#define OpenNoteAPIResourceUpload       @"/yws/open/resource/upload.json" // POST multipart/form-data file
#define OpenNoteAPIResourceDownload     @"/yws/open/resource/download" // GET

#endif
