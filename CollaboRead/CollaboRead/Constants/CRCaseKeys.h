//
//  CaseKeys.h
//  CollaboRead
//
//  Created by Hannah Clark on 10/15/14.
//  Copyright (c) 2014 CollaboRead. All rights reserved.
//

#ifndef CollaboRead_CaseKeys_h
#define CollaboRead_CaseKeys_h

//Groups
#define CR_DB_CASE_SET_ID @"setID"
#define CR_DB_CASE_SET_CASE_LIST @"cases"
#define CR_DB_CASE_SET_OWNERS @"owners"

//Cases
#define CR_DB_CASE_ID @"caseID"
#define CR_DB_CASE_SCANS @"scans"
//#define CR_DB_CASE_IMAGE_LIST @"images" //array
#define CR_DB_CASE_DATE @"date"
#define CR_DB_CASE_NAME @"name"
#define CR_DB_CASE_ANSWERS @"answers" //array
//#define CR_DB_CASE_ANSWER_LECTURER @"lecturer_answer"
#define CR_DB_PATIENT_INFO @"patientInfo"

//Answers
#define CR_DB_ANSWER_ID @"answerID"
#define CR_DB_ANSWER_OWNERS @"owners"
#define CR_DB_ANSWER_DRAWINGS @"drawings"
#define CR_DB_ANSWER_SUBMISSION_DATE @"submissionDate"

//Drawings
#define CR_DB_DRAWING_SCAN_ID @"scanID"
#define CR_DB_DRAWING_SLICE_ID @"sliceID"
#define CR_DB_DRAWING_DATA @"data"

//Drawing Data
#define CR_DB_DRAWING_DATA_X @"x"
#define CR_DB_DRAWING_DATA_Y @"y"
#define CR_DB_DRAWING_DATA_IS_END @"isEnd"

//Scans
#define CR_DB_SCAN_ID @"scanID"
#define CR_DB_SCAN_NAME @"name"
#define CR_DB_SCAN_HAS_DRAWING @"hasDrawing"
#define CR_DB_SCAN_SLICES @"slices"

//Slices
#define CR_DB_SLICE_ID @"sliceID"
#define CR_DB_SLICE_URL @"url"
#define CR_DB_SLICE_HAS_DRAWING @"hasDrawing"

#endif
