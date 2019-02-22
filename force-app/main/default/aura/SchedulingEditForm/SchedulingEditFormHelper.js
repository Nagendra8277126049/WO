({
  closeMe: function (component) {
    this.closeEditForm(component);
    component.destroy();
  },

  popupButtonClickedHelper: function (component, event) {
    try {
      var cmpEvent = event.getSource();
      var eventName = cmpEvent.getLocalId();
      component.set("v.serviceProviderValue", "FedEx");
      component.set("v.isOpenNextDay", false);
      if (eventName === 'EconomyDelivery') {
        component.set("v.deferPopupValue", 'E');
        // add the logic to set the default time
        component.set("v.deferTime", '10:00:00');
      } else
        component.set("v.deferPopupValue", 'S');

      this.DefferalSaveHelper(component);
    } catch (Err) {
      this.showToast(component, 'Error', "Error Occured", "Error");
    }
  },

  // Save Record Helper
  saveRecordHelper: function (component) {
    try {
      var sFlag = component.get("v.isDeferral");
      if (this.validateSave(component)) {
        var IsSameDay = component.get("v.IsSameDay");
        var sameDayFlag = component.get("v.sameDayFlag");
        if (IsSameDay && sameDayFlag) {
          // Defferal Enabled
          this.DefferalSaveHelper(component);
        } else {
          if (sFlag === false) {
            //scheduling Enabled
            this.schedulingSaveHelper(component);
          } else if (sFlag === true) {
            // Defferal Enabled
            this.DefferalSaveHelper(component);
          } else {
            // Throw Error to user 
            this.showToast(component, 'Error', "Error Occured", "Error");
          }
        }
      }
    } catch (Err) {
      this.showToast(component, 'Error', "Error Occured", "Error");
    }
  },

  //Show Toast
  showToast: function (component, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      "title": title,
      "message": message,
      "type": type,
      "mode": "pester",
      "duration": "3000"
    });
    toastEvent.fire();
  },

  //Get Slots When Component is loading
  getSlots: function (component) {
    try {
      // Turn On Spinner
      component.set("v.IsSpinner", true);
      component.set("v.timeValueN", null);
      component.set("v.dateValueN", null);
      var recID = component.get("v.recordId");
      var action = component.get('c.getScheduleSlots');
      var optsDate = [];
      var uniqueOptsDate = [];
      //action.setParams({ workOrderNo: recID });
      action.setParams({
        recordId: recID
      });
      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
            component.set("v.deferralFlag",false);
          var result = response.getReturnValue();
          if (!$A.util.isEmpty(result)) {
            component.set('v.apexResult', result);
            if (result.errorMessage === 'SUCCESS') {
               
              if (!$A.util.isEmpty(result.sWrapperList)) {
                var unique_array = [];
                for (var i = 0; i < result.sWrapperList.length; i = i + 1) {
                  if (!$A.util.isEmpty(result.sWrapperList[i].startDate)) {
                    if (unique_array.indexOf(result.sWrapperList[i].startDate) === -1) {
                      unique_array.push(result.sWrapperList[i].startDate);
                    }
                  }
                }
                optsDate.push({
                  label: "-- None --",
                  value: ""
                });
                for (var j = 0; j < unique_array.length; j = j + 1) {
                  if (!$A.util.isEmpty(unique_array[j])) {
                    optsDate.push({
                      label: unique_array[j],
                      value: unique_array[j]
                    });
                  }
                }
                if (!$A.util.isEmpty(optsDate)) {
                  component.set("v.dateOptions", optsDate);
                }

              }
            }
            else {
            	this.getDeferralSlots(component);
            }
          } else {
            this.getDeferralSlots(component);
          }

          //set response value in objClassController attribute on component
          //component.set('v.objClassController', response.getReturnValue());
          //var hearderValue = component.get('v.objClassController.scheduleSlotListHeader');

          //var slotValue = component.get('v.objClassController.scheduleWrapList');
          /*
          if (!$A.util.isEmpty(slotValue)) {
              optsDate.push({ label: "-- None --",value: "" });
              for (var i = 0; i < hearderValue.length; i = i + 1) {
                  if(uniqueOptsDate.indexOf(hearderValue[i].slotDate) == -1){
                      optsDate.push({
                          label: $A.localizationService.formatDateUTC(hearderValue[i].slotDate, "MMM DD, YYYY"),
                          value: hearderValue[i].slotDate
                      });
                      uniqueOptsDate.push(hearderValue[i].slotDate);
                  }
              }
              component.set("v.dateOptions", optsDate);
          }
          */
        }else {
            this.getDeferralSlots(component);
          }
        // Turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      // Turn Off Spinner
      component.set("v.IsSpinner", false);
      this.getDeferralSlots(component);
    }
  },

  getDeferralSlots: function (component) {
    try {
      // Turn On Spinner
      component.set("v.IsSpinner", true);
      component.set("v.timeValueN", null);
      component.set("v.dateValueN", null);
            component.set("v.isDeferral",true);
      var recID = component.get("v.recordId");
      //var action = component.get('c.getDeferralSlots');
            
            var action = component.get('c.getDeferralSlots');
            
      var optsDate = [];
      //action.setParams({workOrderNo: recID});
      action.setParams({recordId: recID});
      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
            component.set("v.deferralFlag",true);
          //set response value in objClassController attribute on component
          /*
          component.set('v.objClassController', response.getReturnValue());
          var hearderValue = component.get('v.objClassController.scheduleSlotListHeader');
          var slotValue = component.get('v.objClassController.scheduleWrapList');

          if (!$A.util.isEmpty(slotValue)) {
              optsDate.push({label: "-- None --",value: ""});
              for (var i = 0; i < hearderValue.length; i = i + 1) {
                  optsDate.push({
                      label: $A.localizationService.formatDateUTC(hearderValue[i].slotDate, "MMM DD, YYYY"),
                      value: hearderValue[i].slotDate
                  });
              }
              component.set("v.dateOptions", optsDate);
              component.set("v.slaStartDate", component.get('v.objClassController.slaStartDate'));
              component.set("v.slaEndDate", component.get('v.objClassController.slaEndDate'));
              component.set("v.ShiftStart", component.get('v.objClassController.shiftStart'));
              component.set("v.ShiftEnd", component.get('v.objClassController.shiftEnd'));
              
            */

          var result = response.getReturnValue();
          if (!$A.util.isEmpty(result)) {
            component.set('v.apexResult', result);
            if (result.errorMessage === 'SUCCESS') {
              if (!$A.util.isEmpty(result.sWrapperList)) {
                var unique_array = [];
                var uniqueVal_array = [];
                for (var i = 0; i < result.sWrapperList.length; i = i + 1) {
                  if (!$A.util.isEmpty(result.sWrapperList[i].startDate)) {
                    if (unique_array.indexOf(result.sWrapperList[i].startDate) === -1) {
                      unique_array.push(result.sWrapperList[i].startDate);
                      uniqueVal_array.push(result.sWrapperList[i].startDateVal);
                    }
                  }
                }
                optsDate.push({
                  label: "-- None --",
                  value: ""
                });
                for (var j = 0; j < unique_array.length; j = j + 1) {
                  if (!$A.util.isEmpty(unique_array[j])) {
                    optsDate.push({
                      label: unique_array[j],
                      value: uniqueVal_array[j]
                    });
                  }
                }
                
                if (!$A.util.isEmpty(optsDate)) {
                  component.set("v.dateOptions", optsDate);
                }
                component.set("v.dateOptions", optsDate);
                component.set("v.slaStartDate", result.slaStartDate);
                component.set("v.slaEndDate", result.slaEndDate);
                component.set("v.ShiftStart", result.shiftStart);
                component.set("v.ShiftEnd", result.shiftEnd);
              }
            }
          } else {

          }
        }
        // Turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      // Turn Off Spinner
      component.set("v.IsSpinner", false);
    }
  },

  getTimeValues: function (component, dateValue) {
        
    var timeList = [];
    var deferralFlag= component.get("v.deferralFlag");
    /*
        var slotValue = component.get('v.objClassController.scheduleWrapList');
    timeList.push({
      label: "-- None --",
      value: ""
    });
    for (var i = 0; i < slotValue.length; i = i + 1) {
      for (var j = 0; j < slotValue[i].sectionSlotList.length; j = j + 1) {
        if (slotValue[i].sectionSlotList[j].slotDate === dateValue) {
          timeList.push({
            label: slotValue[i].sectionSlotList[j].slotStartEndTime,
            value: slotValue[i].sectionSlotList[j].concatenatedStartEndDate
          });
        }
      }
    }
        */
        var result = component.get("v.apexResult");
        var sWrapperList = result.sWrapperList;
        timeList.push({
            label: "-- None --",
            value: ""
        });
        for (var i = 0; i < sWrapperList.length; i=i+1) {
            if ((sWrapperList[i].startDateVal === dateValue && deferralFlag === true) || (sWrapperList[i].startDate === dateValue && deferralFlag === false)) {
                timeList.push({
                    label: sWrapperList[i].startTime + ' - ' + sWrapperList[i].endTime,
                    value: sWrapperList[i].startDateTime + '|' + sWrapperList[i].endDateTime
                });
            }
        }
    return timeList;
  },

  pullDatesHelper: function (component) {
    component.set("v.serviceProviderValue", null);
    component.set("v.validationError", false);
    component.set("v.errorMessage", '');
    //  Turn On Spinner
    component.set("v.IsSpinner", true);
    var optList = [];
    var date = component.find('dateId').get("v.value");
    var locIsSameDay = component.get("v.IsSameDay");
    var displayDD = false;
    var deferralFlag= component.get("v.deferralFlag");
    if (locIsSameDay) {
      var cmpTarget;
      var tmpslaStartDate = component.get("v.slaStartDate");
      var arrSLAStartDate = tmpslaStartDate.split('T');
      if (date === arrSLAStartDate[0]) {
        component.set("v.sameDayFlag", false);
        displayDD = true;
        cmpTarget = component.find("sameDayFlagId");
        $A.util.removeClass(cmpTarget, 'slds-hide');
      } else {
             if (!(deferralFlag)){
                displayDD = true;
            }
          else{
            displayDD = false;
            component.set("v.sameDayFlag", true);
            cmpTarget = component.find("sameDayFlagId");
            $A.util.addClass(cmpTarget, 'slds-hide');
      	}
      }
    } else {
      displayDD = true;
    }
    if (displayDD) {
      if (!$A.util.isEmpty(date)) {
        optList = this.getTimeValues(component, date);
        component.set("v.timeOptions", optList);
      } else {
        optList.push({
          label: "-- None --",
          value: ""
        });
        component.set("v.timeOptions", optList);
      }
    }
    // Turn Off Spinner
    component.set("v.IsSpinner", false);
  },

  // Validate on Click of Save
  validateSave: function (component) {
    try {
      var validate = true;
      component.set("v.validationError", false);
      component.set("v.errorMessage", '');
      var IsSameDay = component.get("v.IsSameDay");
      var sameDayFlag = component.get("v.sameDayFlag");
      if (IsSameDay && sameDayFlag) {
        if ($A.util.isEmpty(component.find('dateId').get("v.value"))) {
          component.set("v.validationError", true);
          component.set("v.errorMessage", 'Please Select Date');
          return false;
        }
        if ($A.util.isEmpty(component.find('timeSameDayId').get("v.value"))) {
          component.set("v.validationError", true);
          component.set("v.errorMessage", 'Please Select Time Slot');
          return false;
        }
        // check for date selected against SLA
        var selectedDate = component.find('dateId').get("v.value");
        var selectedTime = component.find('timeSameDayId').get("v.value");
        var endSLADateTime = $A.localizationService.formatDateTimeUTC(component.get("v.slaEndDate"));
        //var startSLADateTime = $A.localizationService.formatDateTimeUTC(component.get("v.startEndDate"));
        var startSLADateTime = $A.localizationService.formatDateTimeUTC(component.get("v.slaStartDate"));
        var selectDateTime = $A.localizationService.formatDateTimeUTC(selectedDate + ' ' + selectedTime);
        var endSLADate = $A.localizationService.formatDateUTC(component.get("v.slaEndDate"));
        //var selectDate = $A.localizationService.formatDate(selectDateTime);
        var selectDate = $A.localizationService.formatDateUTC(selectedDate + ' ' + selectedTime);
        var dtendSLADateTime = new Date(endSLADateTime);
        var dtstartSLADateTime = new Date(startSLADateTime);
        var dtselectDateTime = new Date(selectDateTime);

        // validate selected against shift hour
        var locServiceOpt = component.get("v.simpleRecord.Service_Option__c");
        var errorMessage;

        if (locServiceOpt.indexOf('24x7') < 0) {

          var dtShiftStart = new Date(selectedDate + ' ' + component.get("v.ShiftStart"));
          var dtShiftSEnd = new Date(selectedDate + ' ' + component.get("v.ShiftEnd"));

          if ((dtShiftStart > dtselectDateTime) || (dtShiftSEnd < dtselectDateTime)) {
            errorMessage = 'Please Select Time Slot that is between ' + component.get("v.ShiftStart") + ' and ' + component.get("v.ShiftEnd");
            if (dtShiftStart > dtselectDateTime)
              errorMessage = 'Time selected is before the specified start of working hours - ' + component.get("v.ShiftStart");
            if (dtShiftSEnd < dtselectDateTime)
              errorMessage = 'Time selected is after the specified end of working hours - ' + component.get("v.ShiftEnd");
            component.set("v.validationError", true);
            component.set("v.errorMessage", errorMessage);
            return false;
          }


        } else {
          // changes for story#5226566 starts here
          var locServiceType = component.get("v.simpleRecord.Service_Type__c");
          var locCountryCode = component.get("v.simpleRecord.CountryCode");
          if ((locCountryCode === "US") && (locServiceType === "Parts Only") && (locServiceOpt.indexOf("4 Hour") >= 0) && $A.util.isEmpty(component.get("v.serviceProviderValue"))) {
            //var tomorrow = new Date();
            var currentDate = dtstartSLADateTime.getDate();
            var slaDatePlusOne = currentDate + 1;
            if (dtselectDateTime.getDate() === slaDatePlusOne) {
              var tomorrowStart = new Date();
              var tomorrowEnd = new Date();

              tomorrowStart.setDate(tomorrowStart.getDate() + 1);
              tomorrowEnd.setDate(tomorrowEnd.getDate() + 1);
              tomorrowStart.setHours("09", "00", "00", "00");
              tomorrowEnd.setHours("10", "29", "00", "00");
              tomorrowStart = tomorrowStart.getTime();
              tomorrowEnd = tomorrowEnd.getTime();

              var localSelectedTime = dtselectDateTime.getTime();

              if (localSelectedTime >= tomorrowStart && localSelectedTime <= tomorrowEnd) {
                component.set("v.isOpenNextDay", true);
                return false;
                //alert("This Defer Time slot is available for FedEx delivery. FedEx normally delivers most parts by before 10:00am customer time. If customer needs parts at a specific time, then please choose Courier for shipping. See HOW12647 for more information");
              }
            } else
              component.set("v.deferPopupValue", "");
          }
          // changes for story#5226566 ends here
        }

        //if (endSLADate === selectDate) // changes this condition
        //{
          var now = new Date();
          //if (dtendSLADateTime >= dtselectDateTime || now >=dtselectDateTime) {
          //if (dtstartSLADateTime>= dtselectDateTime) {
          if ($A.localizationService.isBefore(dtselectDateTime, dtendSLADateTime)) {
            //if($A.localizationService.isBefore(dtselectDateTime, dtstartSLADateTime)){
            errorMessage = 'Please enter the time that is after current SLA';
            component.set("v.validationError", true);
            component.set("v.errorMessage", errorMessage);
            return false;
          }
        //}

      } else {
        if ($A.util.isEmpty(component.find('dateId').get("v.value")) || $A.util.isEmpty(component.find('timeId').get("v.value"))) {
          component.set("v.validationError", true);
          component.set("v.errorMessage", 'Please select a date and time.Please select a time during the working hours of 8:00 a.m. to 5:00 p.m.');
          return false;
        }
        /*if ($A.util.isEmpty(component.find('timeId').get("v.value"))) {
            component.set("v.validationError", true);
            component.set("v.errorMessage",
                'Please Select Time Slot');
            return false;
        }*/
      }

      return validate;
    } catch (Err) {
      return false;
    }
  },

  callApexToSave: function (component) {
    try {
      //Turn On Spinner
      component.set("v.IsSpinner", true);

      var recID = component.get("v.recordId");
      var dateTime = component.find('timeId').get("v.value");
      var arrDateTime = dateTime.split('|');
      var scheduleStartTime = arrDateTime[0];
      var scheduleEndTime = arrDateTime[1];

      var action = component.get('c.scheduledSlot');

      action.setParams({
        woRecordId: recID,
        scheduleStartTime: scheduleStartTime,
        scheduleEndTime: scheduleEndTime
      });

      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseValue = response.getReturnValue();
            
          if (!$A.util.isEmpty(responseValue)) {
            var arrResponse = responseValue.split('|');
            var responseCode = arrResponse[0];
            var responseMessage = arrResponse[1];
            if (responseCode !== '100') {
              // this.showToast(component, 'Error', responseMessage, "Error"); // DEFECT 5697054 - Commented
                this.getDeferralSlots(component);
            } else {
              // Toast User - Upon Sucess
              this.showToast(component, 'Success', "Updated Work Order Record", "Success");
              // Fire Event - To Update Read View
              this.updateReadForm(component);
              //Close Edit View
              this.closeMe(component);
            }
          } else {
            //this.showToast(component, 'Error', "Error Occured while Calling Service", "Error"); // DEFECT 5697054 - Commented
            
              this.getDeferralSlots(component);
          }
        } else {
          //this.showToast(component, 'Error', "Error Occured while Invoking Service", "Error");
          //DEFECT 5697054 - Commented
          this.getDeferralSlots(component);
        }
        //turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      //Turn Off Spinner
      component.set("v.IsSpinner", false);
      this.showToast(component, 'Error', "Error Occured while Invoking Service", "Error");
    }
  },

  changeTimeSlotHelper: function (component) {
    component.set("v.validationError", false);
    component.set("v.errorMessage", ' ');
    component.set("v.serviceProviderValue", null);
  },

  // fire Event - to open Read View
  closeEditForm: function (component) {
    var openReadFormEvent = component.getEvent("openReadFormEvent");
    var setTrue = true;
    openReadFormEvent.setParams({
      "openReadView": setTrue
    });
    openReadFormEvent.fire();
  },

  //Scheduling Save Helper
  schedulingSaveHelper: function (component) {
    try {
      var status = component.get("v.workOrderStatus");
      if (!$A.util.isEmpty(status)) {
        if (status === 'Work In Progress') {
          // ReSchedule Slots
          this.submittedDispatch(component);
        } else {
          // Non- Submitted Dispatch Scheduling
          if (!component.get("v.IsScheduled")) {
            // Schedule New Slot
            this.callApexToSave(component);

          } else {
            // Cancel Existing  Slot and Create New Slot
            this.nonSubmittedDispatch(component);
          }
        }
      } else {
        this.showToast(component, 'Error', "Work Order Status Field Cannot be Blank", "Error");
      }
    } catch (Err) {
      this.showToast(component, 'Error',
        "Error Occured while Scheduling", "Error");
    }
  },

  nonSubmittedDispatch: function (component) {
    try {
      // Turn On Spinner
      component.set("v.IsSpinner", true);

      var recID = component.get("v.recordId");
      var dateTime = component.find('timeId').get("v.value");
      var arrDateTime = dateTime.split('|');
      var scheduleStartTime = arrDateTime[0];
      var scheduleEndTime = arrDateTime[1];

      var action = component.get('c.nonSubmittedDispatch');

      action.setParams({
        woRecordId: recID,
        scheduleStartTime: scheduleStartTime,
        scheduleEndTime: scheduleEndTime
      });

      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        var subResp;
        if (state === "SUCCESS") {
          var responseValue = response.getReturnValue();
          if (!$A.util.isEmpty(responseValue)) {
            if (!$A.util.isEmpty(responseValue.cancelResponse)) {
              var cancelResp = responseValue.cancelResponse.split('|');
              if (cancelResp[0] === '100') {
                if (!$A.util.isEmpty(responseValue.submitResponse)) {
                  subResp = responseValue.submitResponse.split('|');
                  if (subResp[0] === '100') {
                    // Sucessfully Updated Record
                    this.updateReadForm(component);
                    this.showToast(component, 'Success', "Updated Work Order Record", "Success");
                    this.closeMe(component);
                  } else {
                    // failed to Scdeledule New Slot
                    //this.showToast(component, 'Error', subResp[1], "Error"); //DEFECT 5697054 - Commented
                    this.getDeferralSlots(component);
                  }
                } else {
                  // failed to Scdeledule New Slot
                  //this.showToast(component, 'Error', "Service: Failed To Schedule New Slot", "Error");
                  //DEFECT 5697054 - Commented
                  this.getDeferralSlots(component);
                }
              } else {
                // Toast ErrorMessage to User - Service Failed to Cancel Slots
                //this.showToast(component, 'Error', cancelResp[1], "Error");
                ////DEFECT 5697054 - Commented
                this.getDeferralSlots(component);
              }
            } else {
              if (!$A.util.isEmpty(responseValue.submitResponse)) {
                subResp = responseValue.submitResponse.split('|');
                if (subResp[0] === '100') {
                  // Sucessfully Updated Record
                  this.updateReadForm(component);
                  this.showToast(component, 'Success', "Updated Work Order Record", "Success");
                  this.closeMe(component);
                } else {
                  // failed to Scdeledule New Slot
                  //this.showToast(component, 'Error', subResp[1], "Error");
                  ////DEFECT 5697054 - Commented
                  this.getDeferralSlots(component);
                }
              } else {
                // failed to Scdeledule New Slot
                //this.showToast(component, 'Error', "Service: Failed To Schedule New Slot", "Error");
                ////DEFECT 5697054 - Commented
                this.getDeferralSlots(component);
              }
            }
          } else {
            // show Error Message to User
            //this.showToast(component, 'Error', "Error Occured While Calling the Service", "Error");
            ////DEFECT 5697054 - Commented
            this.getDeferralSlots(component);
          }
        } else {
          //var errors = response.getError(); //DEFECT 5697054 - Commented
          //this.showToast(component, 'Error', JSON.stringify(errors), "Error"); //DEFECT 5697054 - Commented
          this.getDeferralSlots(component);
        }
        // Turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      // Turn Off Spinner
      component.set("v.IsSpinner", false);
      this.showToast(component, 'Error', "Error Occured While Calling the Service", "Error");
    }
  },

  DefferalSaveHelper: function (component) {
    try {

      // Turn On Spinner
      component.set("v.IsSpinner", true);

      var recID = component.get("v.recordId");
      var scheduleStartTime = '';
      var scheduleEndTime = '';

      var IsSameDay = component.get("v.IsSameDay");
      var sameDayFlag = component.get("v.sameDayFlag");

      if (IsSameDay && sameDayFlag) {
        var DateValue = component.find('dateId').get("v.value");
        var TimeValue = component.find('timeSameDayId').get("v.value");

        if (component.get("v.deferPopupValue") === "E")
          TimeValue = component.get("v.deferTime");

        scheduleStartTime = DateValue + 'T' + TimeValue;
        scheduleEndTime = DateValue + 'T' + TimeValue;
      } else {
        //var recID = component.get("v.recordId");            
        var dateTime = component.find('timeId').get("v.value");
        var arrDateTime = dateTime.split('|');
        scheduleStartTime = arrDateTime[0];
        scheduleEndTime = arrDateTime[1];
      }

      var action = component.get('c.setDeferralDate');
      action.setParams({
        woRecordId: recID,
        entitlementStartDate: scheduleStartTime,
        entitlementEndDate: scheduleEndTime,
        sProvider: component.get('v.serviceProviderValue'),
        deferPopup: component.get('v.deferPopupValue')
      });

      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseValue = response.getReturnValue();
          if (!$A.util.isEmpty(responseValue) &&
            responseValue === '100') {
            // Sucessfully Updated Record
            this.updateReadForm(component);
            this.showToast(component, 'Success', "Updated Work Order Record", "Success");
            this.closeMe(component);
          } else {
            this.showToast(component, 'Error', "Error Occured While Updating Record", "Error");
          }
        } else {
          this.showToast(component, 'Error', "Error Occured While Updating Record", "Error");
        }
        // Turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      // Turn Off Spinner
      component.set("v.IsSpinner", false);
      this.showToast(component, 'Error', "Error Occured While Updating Record", "Error");
    }
  },

  // fire Event - to open Read View
  updateReadForm: function (component) {
    try {
      var scheduleStartTime = '';
      var scheduleEndTime = '';
      var IsSameDay = component.get("v.IsSameDay");
      var sameDayFlag = component.get("v.sameDayFlag");
      if (IsSameDay && sameDayFlag) {
        var DateValue = component.find('dateId').get("v.value");
        var TimeValue = component.find('timeSameDayId').get("v.value");
        scheduleStartTime = DateValue + 'T' + TimeValue;
        scheduleEndTime = DateValue + 'T' + TimeValue;
      } else {
        var dateTime = component.find('timeId').get("v.value");
        if (!$A.util.isEmpty(dateTime)) {
          var arrDateTime = dateTime.split('|');
          scheduleStartTime = arrDateTime[0];
          scheduleEndTime = arrDateTime[1];
        }
      }
      var updateReadFormEvent = component.getEvent("updateReadFormEvent");
      updateReadFormEvent.setParams({
        "updatedStartDateValue": scheduleStartTime,
        "updatedEndDateValue": scheduleEndTime
      });
      updateReadFormEvent.fire();
    } catch (Err) {
      this.showToast(component, 'Error', "Error Occured While Updating Read View", "Error");
    }
  },

  submittedDispatch: function (component) {
    try {
      // Turn On Spinner
      component.set("v.IsSpinner", true);
      var recID = component.get("v.recordId");
      var dateTime = component.find('timeId').get("v.value");
      var arrDateTime = dateTime.split('|');
      var scheduleStartTime = arrDateTime[0];
      var scheduleEndTime = arrDateTime[1];
      var action = component.get('c.rescheduledSlot');
      action.setParams({
        woRecordId: recID,
        scheduleStartTime: scheduleStartTime,
        scheduleEndTime: scheduleEndTime
      });

      action.setCallback(this, function (response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseValue = response.getReturnValue();
          if (!$A.util.isEmpty(responseValue)) {
            var resp = responseValue.split('|');
            if (resp[0] === '100') {
              // Sucessfully Updated Record
              this.updateReadForm(component);
              this.showToast(component, 'Success', "Updated Work Order Record", "Success");
              this.closeMe(component);
            } else {
              // Toast ErrorMessage to User
              this.showToast(component, 'Error', resp[1], "Error");
            }
          } else {
            this.showToast(component, 'Error', "Error Occured While Invoking Service", "Error");
          }
        } else {
          this.showToast(component, 'Error', "Error Occured While Updating Record", "Error");
        }
        // Turn Off Spinner
        component.set("v.IsSpinner", false);
      });
      $A.enqueueAction(action);
    } catch (Err) {
      // Turn Off Spinner
      component.set("v.IsSpinner", false);
      this.showToast(component, 'Error', "Error Occured While Updating Record", "Error");
    }
  },

  recordUpdatedHelper: function (component, event) {
    try {
      var eventParams = event.getParams();
      var sameDay;
      var ServiceOpt;
      var serOpt;
      var serviceLevel;
      if (eventParams.changeType === "CHANGED") {
        // get the fields that are changed for this record
        var changedFields = JSON.stringify(eventParams.changedFields);
                if (changedFields.includes("Schedule_Enable_Flag__c")) {
                    var schedulingFlag = component.get("v.simpleRecord.Schedule_Enable_Flag__c");
                    if(schedulingFlag === 'Y' || schedulingFlag === 'y' ){
                        this.getSlots(component);
                    } else {
                        this.getDeferralSlots(component);
                    }
                }
        if (changedFields.includes("Service_Option__c")) {
          sameDay = false;
          ServiceOpt = component.get("v.simpleRecord.Service_Option__c");
          if (!$A.util.isEmpty(ServiceOpt)) {
            serOpt = ServiceOpt.split('-');
            serviceLevel = serOpt[0];
            if (serviceLevel.includes("Hour") || serviceLevel.includes("Remote")) {
              sameDay = true;
            }
          }
          if (sameDay) {
            component.set("v.IsSameDay", sameDay);
          }
        }
      } else if (eventParams.changeType === "LOADED") {
                var schedulingFlag = component.get("v.simpleRecord.Schedule_Enable_Flag__c");
          		if(schedulingFlag === 'Y'){
                    this.getSlots(component);
                } else {
                    this.getDeferralSlots(component);
                }
        sameDay = false;
        ServiceOpt = component.get("v.simpleRecord.Service_Option__c");
        if (!$A.util.isEmpty(ServiceOpt)) {
          serOpt = ServiceOpt.split('-');
          serviceLevel = serOpt[0];
          if (serviceLevel.includes("Hour") || serviceLevel.includes("Remote")) {
            sameDay = true;
          }
        }
        if (sameDay) {
          component.set("v.IsSameDay", sameDay);
        }
      } else if (eventParams.changeType === "ERROR") {
        this.showToast(component, 'Error', "Error Occured", "Error");
      }
    } catch (Err) {
      this.showToast(component, 'Error', "Error Occured", "Error");
    }
  },

  gotoKBURLHelper: function () {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "https://kb.dell.com/infocenter/index?page=content&id=HOW12647"
    });
    urlEvent.fire();
  },
})