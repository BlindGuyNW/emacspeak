# org.emacspeak.nature
from boopak.package import *
from boopak.argdef import *
from boodle import agent
from boodle import builtin

play = bimport('org.boodler.play')
birds = bimport('org.emacspeak.birds')

ca_mocks = [
    birds.mocking_1, birds.mocking_2, birds.mocking_3,  # Northern Mocking Bird
    birds.mocking_4, birds.mocking_5]

fl_mocks = [birds.fl_mocking_1, birds.fl_mocking_2, birds.fl_mocking_3,  # Florida Mocking Bird
            birds.fl_mocking_4, birds.fl_mocking_5, birds.fl_mocking_6]


class FlMockingBirds(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=5.0,
             maxDelay=10.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            1.0, 1.0,  # pitch
            self.minVol, self.maxVol,
            self.pan,
            fl_mocks)
        self.sched_agent(ag)


class CaMockingBirds(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=4.0,
             maxDelay=12.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            1.0, 1.0,  # pitch
            self.minVol, self.maxVol,
            self.pan,
            ca_mocks)
        self.sched_agent(ag)


class MockingBirds (agent.Agent):

    def run(self):
        ag = CaMockingBirds(5.0, 10.0, 0.1, 0.5, 1.0)
        self.sched_agent(ag)
        ag = CaMockingBirds(30.0, 60.0, 0.1, 0.4, 1.2)
        self.sched_agent(ag)
        ag = CaMockingBirds(60.0, 90.0, 0.1, 0.3, 1.5)
        self.sched_agent(ag)
        ag = FlMockingBirds(5.0, 30.0, 0.05, 0.3, 1.0)
        self.sched_agent(ag)
        ag = FlMockingBirds(30.0, 75.0, 0.1, 0.3, 1.2)
        self.sched_agent(ag)
        ag = FlMockingBirds(10.0, 120.0, 0.1, 0.4, 1.5)
        self.sched_agent(ag)


class ManyMockingBirds (agent.Agent):

    def run(self):
        for i in xrange(5):
            ag = CaMockingBirds(
                5.0, 90.0,
                0.1, 0.5,
                1.0 + i * 0.2)
            self.sched_agent(ag)
        for i in xrange(6):
            ag = FlMockingBirds(
                5.0, 120.0,
                0.1, 0.3,
                1.0 + i * 0.2)
            self.sched_agent(ag)
