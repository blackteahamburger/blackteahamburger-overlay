# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_OPTIONAL="1"
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit cmake-multilib distutils-r1 flag-o-matic

if [[ ${PV} == *9999* ]] ; then
	EGIT_REPO_URI="https://github.com/google/${PN}.git"
	inherit git-r3
else
	GIT_COMMIT="440e03642b891968a76b6d088d70f01f06e0c349"
	KEYWORDS="~amd64"
	SRC_URI="
		https://github.com/google/${PN}/archive/${GIT_COMMIT}.tar.gz
			-> ${P}.tar.gz
	"
	S="${WORKDIR}/${PN}-${GIT_COMMIT}"
fi

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli/"

LICENSE="MIT python? ( Apache-2.0 )"
SLOT="0/$(ver_cut 1)"
IUSE="python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

RDEPEND="
	python? ( ${PYTHON_DEPS} )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	python? (
		${DISTUTILS_DEPS}
		test? (
			$(python_gen_cond_dep '
				dev-python/unittest-or-fail[${PYTHON_USEDEP}]
			' 3.{10..11})
		)
	)
"

DOCS=( README.md CONTRIBUTING.md )

src_prepare() {
	cmake_src_prepare
	use python && distutils-r1_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
	)
	cmake_src_configure
}

src_configure() {
	append-lfs-flags

	cmake-multilib_src_configure
	use python && distutils-r1_src_configure
}

src_compile() {
	cmake-multilib_src_compile
	use python && distutils-r1_src_compile
}

python_test() {
	eunittest -s python -p "*_test.py"
}

src_test() {
	cmake-multilib_src_test
	use python && distutils-r1_src_test
}

multilib_src_install() {
	cmake_src_install
}

multilib_src_install_all() {
	use python && distutils-r1_src_install

	doman docs/brotli.1

	local page
	for page in constants decode encode types ; do
		newman docs/${page}.h.3 ${PN}_${page}.h.3
	done
}
