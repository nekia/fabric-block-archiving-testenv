package smoke_test

import (
	"os"
	"path/filepath"
	"strings"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"github.com/hyperledger/fabric-test/tools/operator/testclient"
)

var _ = Describe("Smoke Test Suite", func() {

	Describe("Running Smoke Test Suite in fabric-test", func() {
		var (
			action        string
			inputSpecPath string
		)
		It("Running end to end (old cc lifecycle)", func() {
			inputSpecPath = "./smoke-test-input.yml"

			By("1) Creating channel")
			action = "create"
			err := testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			By("2) Joining Peers to channel")
			action = "join"
			err = testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			By("3) Updating channel with anchor peers")
			action = "anchorpeer"
			err = testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			By("4) Installing Chaincode on Peers")
			action = "install"
			err = testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			By("5) Instantiating Chaincode")
			action = "instantiate"
			err = testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			By("8) Sending Invokes")
			action = "invoke"
			err = testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())
		})

		It("Running end to end (old cc lifecycle)", func() {
			inputSpecPath = "./smoke-test-input-invoke.yml"

			By("9) Sending Invokes 2")
			action := "invoke"
			err := testclient.Testclient(action, inputSpecPath)
			Expect(err).NotTo(HaveOccurred())

			count := getBlockfileCount("peer0-org1")
			Expect(count).Should(Equal(10))
		})
	})
})

func getBlockfileCount(peerName string) int {
	var count int = 0
	filepath.Walk("backup", func(path string, info os.FileInfo, err error) error {
		if strings.Contains(path, peerName) {
			if strings.Contains(path, "blockfile_") {
				count++
			}
		}
		return nil
	})
	return count
}
