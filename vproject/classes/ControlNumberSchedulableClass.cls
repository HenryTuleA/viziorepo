global class ControlNumberSchedulableClass implements Schedulable {
   global void execute(SchedulableContext ctx) {
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :ctx.getTriggerId()];

   }   
}