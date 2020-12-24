let stimulusApplication;

export default {
  get () {
    return stimulusApplication
  },
  get application () {
    return stimulusApplication
  },
  get current () {
    return stimulusApplication
  },
  set(application) {
    stimulusApplication = application
  },
  set application (application) {
    stimulusApplication = application
  }
}
