﻿namespace GH.UnitTests.Entities.Subscription
{
    using GH.Utils.Entities;

    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using GH.Utils.Entities.Subscription;

    using Moq;

    [TestClass]
    public class EntityUpdateSubscriptionCenterTests
    {
        private EntityUpdateSubscriptionCenter<IIdObject<string>, string> subscriptionCenterUnderTest;

        [TestInitialize]
        public void TestInitialize()
        {
            this.subscriptionCenterUnderTest = new EntityUpdateSubscriptionCenter<IIdObject<string>, string>();
        }

        private static IIdObject<string> MakeObject(string id)
        {
            var mock = new Mock<IIdObject<string>>();
            mock.Setup(o => o.Id).Returns(id);
            return mock.Object;
        }

        [TestMethod]
        public void TestEntityUpdateSubscriptionCenterSubscribeForUpdates()
        {
            var o1 = MakeObject("id1");
            var trigged = false;

            this.subscriptionCenterUnderTest.SubscribeForUpdates(
                (e) =>
                    {
                        Assert.AreEqual(o1, e);
                        trigged = true;
                    });
            this.subscriptionCenterUnderTest.TriggerSubscriptionUpdate(o1);

            Assert.IsTrue(trigged, "The callback method was not tiggered.");
        }

        [TestMethod]
        public void TestEntityUpdateSubscriptionCenterSubscribeForUpdatesWithFilter()
        {
            var o1 = MakeObject("id1");
            var o2 = MakeObject("id2");
            var trigged = false;

            this.subscriptionCenterUnderTest.SubscribeForUpdates(
                (e) =>
                {
                    Assert.AreEqual(o2, e);
                    trigged = true;
                }, (e) => e == o2);

            this.subscriptionCenterUnderTest.TriggerSubscriptionUpdate(o1);
            Assert.IsFalse(trigged, "The callback method was tiggered on wrong object.");

            this.subscriptionCenterUnderTest.TriggerSubscriptionUpdate(o2);
            Assert.IsTrue(trigged, "The callback method was not tiggered.");
        }
    }
}