# On Call

This document is a comprehensive resource for developers that are on call

## Goals

- All team members share responsibility and ownership of the product
- Team members who are not on call can disconnect outside of work hours
    - This setup establishes a mechanism for people to be brought in as needed, removing the need for checking in on slack or email
- Response plans are documented.
    - We always know who is on call and how issues will be handled
    - Incidents are being handled in a reliable, documented way. Less on a case-by-case basis
    - No more last-minute asking for a contact sheet

## Responsibilities

- On-call to support the Android (Google) and Fire (Amazon) apps for both Disney+ and Star+.
- Slack handle - **@disney-plus-android-on-call**
    - This handle is tied to the person/people on call, plus Aaron Rietschlin, Semir Murselovic and Erik Dekker for visibility and backup.
    - **Regular on-call shifts** - the person on call is not expected to be actively watching the channels, however they are expected to respond to PagerDuty alerts and ideally to Slack notifications. It’s expected that Slack notifications are enabled on phone/desktop, but it’s understood that a ping on Slack isn’t always seen within a couple of minutes.
    - **For eyes-on-glass shifts** - it’s expected that the person on call responds to Slack notifications. Support channel(s) should be periodically checked.

### Priorities

- First priority is to respond to production issues as they are reported.
    - A Slack thread is opened in **#disneyplus-support-general** or **#starplus-support-general**
    - If the issue seems to be related to Android and/or Fire, the Android on-call handle will be used to get the attention of the on-call engineer.
    - If the severity of the issue is high (1 or 2) and nobody responds in Slack, a PagerDuty alert is triggered (phone/text/app alarm).
    - The on-call engineer, or anyone else from the Android team that happens to see the thread should respond immediately, acknowledging that the team is engaged. See the Playbook below for how to proceed.
- Second priority is to respond to issues in QA that are blocking other teams.
- It can happen that on-call engineers are asked to do configuration changes; for example dictionary updates. Work with at least one other team member to make the change and get it deployed.
- On-call engineers should prioritize alerts over stories assigned to them for the sprint. Don’t forget to communicate with the TPM if this happens.

## Slack Channels

| Slack Channel               | Types of Alarms and Errors                                                                                                                                                                                                        |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **#disneyplus-support-general** | Updates, questions and issues related to Disney+ are reported and discussed here (in Slack threads).                                                                                                                              |
| **#starplus-support-general**   | Updates, questions and issues related to Star+ are reported and discussed here (in Slack threads).                                                                                                                                |
| **#qe-dplus** & **#qe-starplus**    | QE shift summaries and discussion                                                                                                                                                                                                 |
| **#ds-android-qa**              | Updates, questions and issues are discussed here when in Feature Complete, Release Candidate and development state from QA.                                                                                                       |
| **#ds-android-devs**            | Internal Android dev channel to discuss incident details with other team members if needed. Use @here to get the attention of team members in case help is needed with investigating, testing, reviewing config deployments, etc. |

## Playbook

- [See AAW playbook for general info](https://docs.google.com/document/d/1rYDi2WcwhTag5OBOoiQrlfw62tlQTqb9Jx-z9P-5xkE/edit)

### How to respond to a question in Slack

- Acknowledge. You should immediately reply in the thread that you’ve seen the message and that you will investigate on behalf of the Android team.
- Verify the report is actionable or request more information
- Identify areas for investigation
- Ask secondary or other team’s oncall if needed, for example SDK support. PSO (the folks managing the incidents) know other teams’ on-call handles and/or PagerDuty distro’s if needed.
- Regularly communicate progress, even if there is no progress.
- Continue to be helpful even if it turns out the issue is not (just) an Android client issue

### How to do a preliminary investigation

- Collect any available logs from the reporter
- Attempt to reproduce
- Identify the cause
- Add this information to an existing JIRA or create a JIRA
- Communicate the JIRA link/ticket number in the support thread
- Tell your team what you are doing by posting in the #dplus-android-devs channel, link to the support thread(s) and other relevant information
- For Sev 4 incidents, the INC will now be transitioned to JIRA, meaning that it’s no longer being actively tracked by the PSO team. It is expected that the development team picks up the ticket and brings it to production to address the issue.
- Keep the JIRA ticket up to date with recent and accurate information. Remember that this ticket will be used as a source of truth by other teams tracking the incident.

### Helpful questions to ask yourself (or others) when investigating

- Is the issue only occurring on Android/Fire? What about Apple, Web, Connected Devices?
- Do we support this device?
    - We support Android version 5.0 and higher.
    - On Android, we only support Certified Google devices. You can find certified devices in the Play Store Device Catalog.
    - On Android, we only support devices that pass Google’s SafetyNet check. This means that rooted and unlocked devices, as well as devices with beta firmware, are not supported.
        - There are various apps available [on the Play Store](https://play.google.com/store/apps/details?id=org.freeandroidtools.safetynettest) that can check the SafetyNet status of a device
- Is the issue really an issue or is a feature working as designed? Look for relevant JIRA tickets.
- Is there an issue with signup or IAP? Check if the country is a “Login Only” country or not. Signup and IAP can also be suppressed on a per-device basis. This is typically done for partner devices. See this wiki page.
Has the issue been introduced recently (in a recent app update, for example) or has the issue existed for a longer time.
- How many users run into this issue in production?
- Is the issue recoverable by the user?
- Who can I ask for help? Who knows more about this part of the app/service?

### Asking for help

- [Find the relevant subteam](https://github.bamtech.co/pages/Android/dmgz-docs/administrative/org/) and pull in their on-call engineer
- Escalate if applicable (see below)
- Ask for help in the dev channel

### How to proceed when the issue has been identified

- It’s never the expectation that the on-call engineer fixes a client bug and proceeds with a release. If an issue can only be addressed by an app update, it needs to be escalated to the various Android team leads and director (Aaron Rietschlin).
- If the issue can only be fixed by an app update, it’s helpful but not required that the on-call engineer works on a fix and puts up a PR. Use common sense to determine which subteam or engineer should work on a fix.
- If the issue can be fixed or a workaround is possible with a config change, work with at least one team lead to make the change and do the deployment. Communicate about this fix and (timing of) deployment.
- If you know how users can work around the issue, post the detailed steps in the support chat. Customer support can then use this information when people call in.
- If you come up with a workaround/solution that requires action from another team, communicate in the thread. PSO can help identify and pull in other teams.

### When and how to escalate

- Rely on the Sev level.
- **Sev 4 and above** - can be ack’d, ticketed and left for the next business day if needed.
- **Sev 3** - should have a fix identified and a mitigation deployed ASAP. The implementation and deployment schedule of a proper fix can be determined with stakeholders the next business day.
- **Sev 1,2** - all hands on deck. A fix should be identified, a mitigation deployed ASAP. Implementation and deployment schedule of a proper fix should also be determined with stakeholders ASAP.
- Escalation phone numbers:
    - **Aaron Rietschlin: +1 419-310-1521**

### Accounts needed and how to get them

- **PagerDuty** - reach out to your TPM if you don’t have an account yet. You will need to install the mobile app and set it up in order to respond to PD incidents.
- **Sentry** - reach out to Remco Mokveld, Aaron Rietschlin or Nate Lefler to get invited
- **Kibana (DUST)** - [Open on VPN](https://search-bta-dust-events-prod-bh7pvrnwyp6brivb6ia5hwra2i.us-east-1.es.amazonaws.com/_plugin/kibana/app/kibana)
- **Conviva (optional)** - SNOW request, or reach out to your TPM
- **Play Store** - for crashes and IAP data (leads only)

### Eyes-on-glass

- Eyes-on-glass (EOG) means actively being online and monitoring the channels, dashboards, etc.
- EOG is not usually required.
- During important launches or other milestones, it can happen that EOG shifts are required. This will be made explicit in the schedule.
- For EOG shifts, it’s required to do a proper “handoff” to the next person on shift (if any).
    - Setup a call or discuss with this person on Slack how things went.
    - Share notes, links to Slack threads, etc.
    - Loop the next person into ongoing conversations.

### Who goes on call

- All Senior Engineers and Team Leads - P3+
- Additional engineers will be determined by each subteam.

### On-call schedules

- [Star+ Launch](https://docs.google.com/spreadsheets/d/1XwOMpkVAuO2O3rvniRJf3m7tcpdiPVnx52Cgj2ENcI0/edit#gid=1857377801)
- [Welch](https://docs.google.com/spreadsheets/d/1OWJyP-RrfxzuCj_8CUInX1GZKPpg-jOV78KQ0mDZsZI/edit#gid=937689387 )
- [LATAM Launch](https://docs.google.com/spreadsheets/d/1XwOMpkVAuO2O3rvniRJf3m7tcpdiPVnx52Cgj2ENcI0/edit?usp=sharing)
- [Tini Concert Coverage May 28 2022](https://docs.google.com/spreadsheets/d/1Ic5B3L6KS4DTa73l9L6szR8jvVLMXFmXPRUAVlY_rsc/edit#gid=2089063948)
